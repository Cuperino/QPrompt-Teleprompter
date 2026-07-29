#**************************************************************************
#
# QPrompt
# Copyright (C) 2026 Javier O. Cordero Pérez
#
# This file is part of QPrompt.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#**************************************************************************

# Manual-test NCS peer (POSIX only): drives a connected QPrompt over MOS.
add_executable(qprompt-mos-ncs-peer main.cpp)
target_link_libraries(qprompt-mos-ncs-peer PRIVATE
    imos::incs
    imos::transports
)
target_compile_features(qprompt-mos-ncs-peer PRIVATE cxx_std_20)
