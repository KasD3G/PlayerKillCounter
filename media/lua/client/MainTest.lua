require "Chat/ISChat"
require "pl.pretty"

local ChatSystem = require("ChatSystem");

local function testDeath()
    print("YEEAH!!! zombie died");
    ChatSystem.addLineToChat("YEEAH!!! zombie died", "<RGB:1,1,1>");
end

local function onMessage(chatMessage, tabId)
    print("LOG : PKC: onMessage=" .. chatMessage:getText());
    print("LOG : PKC: RawMessage=" .. dumb(chatMessage));
end

Events.OnZombieDead.Add(testDeath);
Events.OnAddMessage.Add(onMessage);

