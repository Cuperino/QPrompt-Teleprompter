// Map Gettext translations to Qt Internationalization files

function copyTranslation(message, poDocument, number="") {
    //poDocument.gotoPreviousLine();
    //poDocument.findRegexp("msgctxt \"(.*)\"");
    //const messageContext = poDocument.selectedText.slice(9, -1);
    //poDocument.gotoNextLine();
        //poDocument.gotoNextLine();
    if (number !== "")
        poDocument.findRegexp("msgstr(\[" + number + "\]) \"(.*)\"");
    else
        poDocument.findRegexp("msgstr(\[0\])? \"(.*)\"");
    let messageString = poDocument.selectedText.slice(8, -1);
    poDocument.gotoNextLine();
    let flag = false;
    while (!flag && poDocument.currentLine!==poDocument.lineCount) {
        const currentLine = poDocument.currentLine;
        if (currentLine.length===0 || currentLine.startsWith("#:"))
            flag = true;
        messageString += "\n" + currentLine.slice(1, -1);
        poDocument.gotoNextLine();
    }
    // FixMe: make sure all lines match, not just the first
    //if (messageContext === message.comment)
        message.translation = messageString;
    //else
    //    message.translation = "";
    //Message.log(message.source);
    //Message.log(message.translation);
}

function main() {
    // let ts = Project.allFilesWithExtension("ts", Project.FullPath);
    // let i = 0;
    let j = 0;
    // for(i=0; i<ts.length; i++) {
        let tsDocument = Project.currentDocument;
        // let tsDocument = Project.open(ts[i]);
        const language = tsDocument.language;
        const poPath = "po/" + language + ".po";
        const poDocument = Project.get(poPath);
        //if (poDocument.exists)
        //    Message.log(poDocument.documentName);
        //else
        //    Message.error(poDocument.errorString + ": " + poPath);
        if (poDocument.exists) {
            // Traverse messages
            for(j=0; j<tsDocument.messages.length; j++) {
                // message.translation = "";  // For debugging
                let message = tsDocument.messages[j];
                poDocument.position = 0;
                // Plural
                if (poDocument.find("msgid_plural \"" + message.source + "\""))
                    copyTranslation(message, poDocument, "1");
                // Singular
                // Single line exact match
                else if (poDocument.find("msgid \"" + message.source + "\""))
                    copyTranslation(message, poDocument);
                // Possibly a multi-line message
                else {
                    poDocument.position = 0;
                    let found = false;
                    while (poDocument.find("msgid \"\"")) {
                        poDocument.gotoNextLine();
                        const currentLine = poDocument.currentLine.slice(1, -1);
                        // FixMe: make sure that all lines match, not just the first
                        if (message.source.startsWith(currentLine)) {
                            found = true;
                            break;
                        }
                    }
                    // Multi-line message found
                    if (found)
                        copyTranslation(message, poDocument);
                    else {
                        Message.warning("Missing: " + message.source);
                        message.translation = "";
                    }
                }
            }
            for(j=0; j<tsDocument.messages.length; j++) {
                let message = tsDocument.messages[j];
                message.translation = message.translation.replace("…", "…")
            }
        }
    // }
    return j;
}
