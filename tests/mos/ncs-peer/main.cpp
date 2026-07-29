/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, version 3 of the License.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

// Manual-test NCS peer for QPrompt's MOS integration. Runs a MOS 4.0
// WebSocket server (default port 10540) with the incs NCS role and takes
// commands on stdin to drive a connected QPrompt:
//
//   info                      request the prompter's machine info (Profile 0)
//   ready|execute|pause|stop|signal [roID [storyID [itemID]]]
//                             send roCtrl at RO/story/item scope (Profile 5)
//   cue [storyID [itemID]]    send a roItemCue notification (Profile 5)
//   quit                      exit
//
// Point QPrompt at ws://127.0.0.1:<port>/mos with matching MOS ID / NCS ID.
// POSIX-only (select() on stdin); this is a test tool, not a product.
//
// Usage: qprompt-mos-ncs-peer [port] [mosID] [ncsID] [--utf8]

#include <sys/select.h>
#include <unistd.h>

#include <chrono>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <memory>
#include <sstream>
#include <string>
#include <thread>
#include <vector>

#include <imos/session/in_memory_store.h>
#include <imos/transports/ws40.h>
#include <incs/ncs.h>

namespace {

namespace ws40 = imos::transports::ws40;

class SystemClock : public imos::IClock {
public:
    imos::MonotonicTime now() override {
        const auto steady = std::chrono::steady_clock::now().time_since_epoch();
        return imos::MonotonicTime{
            std::chrono::duration_cast<std::chrono::milliseconds>(steady).count()};
    }
    imos::WallClockTime wallClock() override {
        const auto system = std::chrono::system_clock::now().time_since_epoch();
        return imos::WallClockTime{
            std::chrono::duration_cast<std::chrono::milliseconds>(system).count()};
    }
};

bool stdinReadable() {
    fd_set readSet;
    FD_ZERO(&readSet);
    FD_SET(STDIN_FILENO, &readSet);
    timeval timeout{0, 0};
    return select(STDIN_FILENO + 1, &readSet, nullptr, nullptr, &timeout) > 0;
}

const char* eventName(imos::SessionEventType type) {
    using imos::SessionEventType;
    switch (type) {
        case SessionEventType::MessageReceived: return "MessageReceived";
        case SessionEventType::AckReceived: return "AckReceived";
        case SessionEventType::DeliveryFailed: return "DeliveryFailed";
        case SessionEventType::ChannelFault: return "ChannelFault";
        case SessionEventType::DuplicateSuppressed: return "DuplicateSuppressed";
        case SessionEventType::ProtocolError: return "ProtocolError";
        case SessionEventType::StoreError: return "StoreError";
        case SessionEventType::ResyncNeeded: return "ResyncNeeded";
        case SessionEventType::ForeignObjectReferenced: return "ForeignObjectReferenced";
    }
    return "?";
}

}  // namespace

int main(int argc, char** argv) {
    int port = 10540;
    std::string mosID = "qprompt.local";
    std::string ncsID = "ncs.test.local";
    auto wire = imos::encoding::WireEncoding::Ucs2Be;
    std::vector<std::string> positional;
    for (int i = 1; i < argc; ++i) {
        if (std::strcmp(argv[i], "--utf8") == 0) {
            wire = imos::encoding::WireEncoding::Utf8;
        } else {
            positional.emplace_back(argv[i]);
        }
    }
    if (positional.size() > 0) port = std::stoi(positional[0]);
    if (positional.size() > 1) mosID = positional[1];
    if (positional.size() > 2) ncsID = positional[2];

    SystemClock clock;
    imos::InMemoryMessageStore store;

    ws40::ServerConfig serverConfig;
    serverConfig.host = "0.0.0.0";
    serverConfig.port = port;
    ws40::Ws40Server server{serverConfig};
    ws40::ServerPeerConfig peer;
    peer.mosID = mosID;
    peer.ncsID = ncsID;
    peer.wireEncoding = wire;
    if (const auto added = server.addPeer(peer); !added.ok()) {
        std::fprintf(stderr, "addPeer failed: %s\n", added.error().message.c_str());
        return 1;
    }
    if (const auto started = server.start(); !started.ok()) {
        std::fprintf(stderr, "server start failed: %s\n", started.error().message.c_str());
        return 1;
    }

    imos::SessionConfig session;
    session.mosID = mosID;
    session.ncsID = ncsID;
    session.keepAliveIntervalMillis = 30'000;
    session.wireEncode.encoding = wire;
    session.wireDecode.encoding = wire;

    imos::profiles::MachineInfo info;
    info.manufacturer = "QPrompt project";
    info.model = "NCS test peer";
    info.swRev = "1.0";
    info.id = ncsID;
    info.deviceType = imos::profiles::DeviceType::Ncs;
    info.profiles = {true, true, true, false, true, true, false, true};

    incs::Ncs ncs{{session, info},
                  imos::PeerSession::Dependencies{
                      &clock, &server.transportFor(mosID, ncsID), &store}};

    std::printf("NCS peer on ws://0.0.0.0:%d  mosID=%s  ncsID=%s  wire=%s\n", server.port(),
                mosID.c_str(), ncsID.c_str(),
                wire == imos::encoding::WireEncoding::Utf8 ? "UTF-8" : "UCS-2 BE");
    std::printf("Commands: info | ready|execute|pause|stop|signal [ro [story [item]]] | cue [story [item]] | quit\n");

    const std::string defaultRoID = "QPROMPT.TEST.RO";
    bool running = true;
    std::string pending;
    while (running) {
        while (auto event = server.nextEvent()) {
            using Kind = ws40::ServerEvent::Kind;
            switch (event->kind) {
                case Kind::ChannelConnected:
                    std::printf("[peer] channel %s connected\n",
                                std::string{imos::channelName(event->channel)}.c_str());
                    ncs.onChannelConnected(event->channel);
                    break;
                case Kind::ChannelDisconnected:
                    std::printf("[peer] channel %s disconnected\n",
                                std::string{imos::channelName(event->channel)}.c_str());
                    ncs.onChannelDisconnected(event->channel);
                    break;
                case Kind::Frame:
                    ncs.onFrameReceived(event->channel, event->frame);
                    break;
                case Kind::ProtocolError:
                case Kind::Rejected:
                    std::printf("[peer] transport: %s\n", event->diagnostic.c_str());
                    break;
            }
        }
        ncs.poll();
        while (auto event = ncs.nextEvent()) {
            std::printf("[peer] event %s %s\n", eventName(event->type),
                        event->diagnostic.c_str());
        }
        while (auto result = ncs.nextCtrlResult()) {
            std::printf("[peer] roAck for seq %llu: %s (%s)\n",
                        static_cast<unsigned long long>(result->seq),
                        result->ok ? "OK" : "NACK", result->roStatus.c_str());
        }
        while (auto cue = ncs.nextItemCue()) {
            std::printf("[peer] roItemCue from device: ro=%s story=%s item=%s type=%s time=%s\n",
                        cue->roID.c_str(), cue->storyID.c_str(), cue->itemID.c_str(),
                        cue->roEventType.c_str(), cue->roEventTime.c_str());
        }
        if (const auto* peerInfo = ncs.peerMachineInfo(); peerInfo != nullptr && pending == "info") {
            pending.clear();
            std::printf("[peer] device: %s %s %s (MOS %s)\n", peerInfo->info.manufacturer.c_str(),
                        peerInfo->info.model.c_str(), peerInfo->info.swRev.c_str(),
                        peerInfo->info.mosRev.c_str());
            for (int i = 0; i < imos::profiles::kProfileCount; ++i) {
                if (peerInfo->info.profiles[static_cast<std::size_t>(i)]) {
                    std::printf("[peer]   profile %d: YES\n", i);
                }
            }
        }

        if (stdinReadable()) {
            std::string line;
            if (!std::getline(std::cin, line)) {
                running = false;
                break;
            }
            std::istringstream words{line};
            std::string command;
            words >> command;
            std::string roID = defaultRoID;
            std::string storyID;
            std::string itemID;
            if (command == "quit" || command == "exit") {
                running = false;
            } else if (command == "info") {
                pending = "info";
                if (const auto sent = ncs.requestMachineInfo(); !sent.ok()) {
                    std::printf("[peer] reqMachInfo failed: %s\n", sent.error().message.c_str());
                }
            } else if (command == "ready" || command == "execute" || command == "pause" ||
                       command == "stop" || command == "signal") {
                words >> roID >> storyID >> itemID;
                if (roID.empty())
                    roID = defaultRoID;
                auto scope = imos::profiles::CtrlScope::RunningOrder;
                if (!itemID.empty())
                    scope = imos::profiles::CtrlScope::Item;
                else if (!storyID.empty())
                    scope = imos::profiles::CtrlScope::Story;
                const auto ctrl = command == "ready"     ? imos::profiles::CtrlCommand::Ready
                                  : command == "execute" ? imos::profiles::CtrlCommand::Execute
                                  : command == "pause"   ? imos::profiles::CtrlCommand::Pause
                                  : command == "stop"    ? imos::profiles::CtrlCommand::Stop
                                                         : imos::profiles::CtrlCommand::Signal;
                const auto sent = ncs.sendCtrl(scope, roID, storyID, itemID, ctrl);
                if (sent.ok()) {
                    std::printf("[peer] sent roCtrl %s (seq %llu)\n", command.c_str(),
                                static_cast<unsigned long long>(sent.value()));
                } else {
                    std::printf("[peer] roCtrl failed: %s\n", sent.error().message.c_str());
                }
            } else if (command == "cue") {
                words >> storyID >> itemID;
                imos::profiles::ItemCue cue;
                cue.mosID = mosID;
                cue.roID = defaultRoID;
                cue.storyID = storyID.empty() ? "STORY1" : storyID;
                cue.itemID = itemID.empty() ? "ITEM1" : itemID;
                cue.roEventType = "Prompter";
                cue.roEventTime = "2026-01-01T00:00:00Z";
                const auto sent = ncs.sendItemCue(cue);
                if (sent.ok()) {
                    std::printf("[peer] sent roItemCue (seq %llu)\n",
                                static_cast<unsigned long long>(sent.value()));
                } else {
                    std::printf("[peer] roItemCue failed: %s\n", sent.error().message.c_str());
                }
            } else if (!command.empty()) {
                std::printf("[peer] unknown command: %s\n", command.c_str());
            }
        }

        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }

    server.stop();
    return 0;
}
