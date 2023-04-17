if isServer() then
    return
end

PKCMain = {}
Commands = _G['Commands'] or {}
Commands.commands = {};

local thisPlayer = nil;
local thisModData = nil;

local msgColor = "<RGB:181,53,53>";

local ChatSystem = require("ChatSystem");

local lastTabId = 0;
local UCLEN = 17;
local clone = nil;

local original_fun;

local adminTabId;

local weekOffset = 15;

-- local function updateWeekEvent()
--     local calendar = Calendar.getInstance();
--     local dayWeek = calendar:get(Calendar.DAY_OF_WEEK);
--     local weekYear = calendar:get(Calendar.WEEK_OF_YEAR);
--     local playerWeek = tonumber(thisPlayer:getModData().PKCModData.week);

--     if weekYear > playerWeek then
--         thisPlayer:getModData().PKCModData.week = weekYear;
--         print("LOG : PKC: week updated");
--     end
-- end

function PKCMain.updateUI()
    print("LOG : PKC: updating UI");
    sendClientCommand(thisPlayer, "PKC", "updateUI", {});
end

local function drawUI(playerData)
    print("LOG : PKC: drawUI");
    local zText = "Kills: " .. tostring(playerData.pvpKills) .. " <LINE> Points: " .. tostring(playerData.pvpPoints) ..
                      " <LINE> TK: " .. tostring(playerData.pvpTK);
    -- local zText = "TEST <LINE> TEST2"
    BoxTab.HomeWindow.text = zText;
    BoxTab.HomeWindow:paginate();
end

local function splitstr(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}

    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end

    return t
end

local function printMsg(msg, tabId)
    print("LOG : PKC: " .. msg);
    ChatSystem.addLineToChat(msg, msgColor, nil, nil, tabId);
end

local function chatPrintStats(dataPlayer)
    print("LOG : PKC: chatPrintStats");
    local msg = "Kills: " .. tostring(dataPlayer.pvpKills) .. " | Points: " ..
                    tostring(dataPlayer.pvpPoints) .. " | TK: " ..
                    tostring(dataPlayer.pvpTK);
    printMsg(msg, lastTabId);
end

function Commands.OnAddMessage(chatMessage, tabId)

    local clone = chatMessage:clone();
    local messageText = clone:getText():sub(UCLEN);

    local commandArgs = splitstr(messageText);
    local command = commandArgs[1];

    if command ~= nil and command == "pkc" then
        print("LOG : PKC: pkc");
        print("LOG : PKC: accesslevel " .. tostring(thisPlayer:getAccessLevel()));

        if commandArgs[2] == "evento" then
            print("LOG : PKC: evento");
            lastTabId = tabId;
            sendClientCommand(thisPlayer, "PKC", "chatPrintStats", {});

        elseif thisPlayer:getAccessLevel() == "Admin" and commandArgs[2] == "admin" then
            print("LOG : PKC: admin command " .. tostring(thisPlayer:getAccessLevel()));
            adminTabId = tabId;
            sendClientCommand(thisPlayer, "PKC", "admin", {});

        else
            print("LOG : PKC: command not found");
            print("LOG : PKC: color=" .. tostring(chatMessage:getTextColor()));
            ISChat.addLineInChat(chatMessage, tabId);

        end
    else
        ISChat.addLineInChat(chatMessage, tabId);
    end

end

local function onPlayerDead(player)
    if thisPlayer:getUsername() == player:getUsername() then
        print("LOG : PKC: onPlayerDead=" .. tostring(player:getUsername()));
        -- thisModData = thisPlayer:getModData().PKCModData;
        -- tempSave();
    end
end

local function OnCreatePlayer(playerIndex, player)
    print("-------------------------CREATE PLAYER----------------------------------");
    thisPlayer = player
    print("LOG : thisPlayer=" .. tostring(thisPlayer:getUsername()));
    sendClientCommand(thisPlayer, "PKC", "createPlayer", {});
end

local function findKey(tbl, key)
    for k, v in ipairs(tbl) do
        if k == key then
            return true
        end
    end
    return false
end

local function OnWeaponHitCharacter(wielder, character, handWeapon, damage)
    print("-------------------------OnWeaponHIT----------------------------------");
    print("LOG : PKC: wielder getAttackBy= " .. tostring(wielder:getAttackedBy()));
    print("LOG : PKC: character getAttackBy= " .. tostring(character:getAttackedBy()));
    if wielder:isZombie() then
        print("-------------------------ENEMY ZOMBIE----------------------------------");
        print("LOG : LastEnemy= Zombie");
    else
        if not character:isZombie() and character:getUsername() == thisPlayer:getUsername() then
            print("-------------------------ENEMY PLAYER----------------------------------");
            print("LOG : LastEnemy= " .. tostring(wielder:getUsername()));
        else
            -- on hit zombie test here
            print("-------------------------TEST----------------------------------");

        end
    end
end

local function OnServerCommand(module, command, args)
    print("-----------------SERVER COMMAND CLIENT SIDE-----------------");
    if module ~= "PKC" then
        return;
    end
    if command == "PlayerDeath" then
        if thisPlayer:getUsername() == args.attacker then
            print("-------------------------ITS ME!!!----------------------------------");
            print("LOG : PKC: attacek= " .. args.attacker);
            print("LOG : PKC: victim= " .. args.victim);
            print("LOG : PKC: msg= " .. args.msg);

            if args.tempWeek ~= nil then
                ChatSystem.addLineToChat("Punto por matar a " .. args.victim);
            else
                ChatSystem.addLineToChat(args.victim .. " NO da mas puntos para la semana " .. args.tempWeek);
            end

            PKCMain.updateUI();
        end
    elseif command == "getStats" then
        print("-------------------------GET STATS----------------------------------");
        if args.admin == thisPlayer:getUsername() then
            ChatSystem.addLineToChat("------ Server Event Stats ------", "<RGB:1,1,1>", nil, nil, adminTabId);
            ChatSystem.addLineToChat(args.msg, "<RGB:1,1,1>", nil, nil, adminTabId);
        end
    elseif command == "createPlayer" then
        if args.player == thisPlayer:getUsername() then
            print("-------------------------CREATE PLAYER----------------------------------");
            print(args.msg);
        end
    elseif command == "broadcast" then
        -- print("-------------------------BROADCAST----------------------------------");
        -- if args.admin == thisPlayer:getUsername() then
        --     ChatSystem.addLineToChat(args.player .. " = " .. args.stats, "<RGB:1,1,1>", nil, nil, adminTabId);
        -- end
    elseif command == "updateUI" then
        if args.player == thisPlayer:getUsername() then
            if args.playerData ~= nil then
                drawUI(args.playerData);
            else
                print("LOG : PKC: ERROR: updateUI args.playerData is nil");
            end
        end
    elseif command == "chatPrintStats" then
        if args.player == thisPlayer:getUsername() then
            if args.playerData ~= nil then
                chatPrintStats(args.playerData);
            else
                print("LOG : PKC: ERROR: chatPrintStats args.playerData is nil");
            end
        end
    end
end

new_function = function()
    if not isClient() then
        return;
    end
    ISChat.chat = ISChat:new(15, getCore():getScreenHeight() - 400, 500, 200);
    ISChat.chat:initialise();
    ISChat.chat:addToUIManager();
    ISChat.chat:setVisible(true);
    ISChat.chat:bringToTop();
    ISLayoutManager.RegisterWindow('chat', ISChat, ISChat.chat);

    ISChat.instance:setVisible(true);

    -- replace old handler with our new handler
    Events.OnAddMessage.Add(Commands.OnAddMessage);
    Events.OnMouseDown.Add(ISChat.unfocusEvent);
    Events.OnKeyPressed.Add(ISChat.onToggleChatBox);
    Events.OnKeyKeepPressed.Add(ISChat.onKeyKeepPressed);
    Events.OnTabAdded.Add(ISChat.onTabAdded);
    Events.OnSetDefaultTab.Add(ISChat.onSetDefaultTab);
    Events.OnTabRemoved.Add(ISChat.onTabRemoved);
    Events.SwitchChatStream.Add(ISChat.onSwitchStream);
end

Events.OnGameBoot.Add(function()
    Events.OnGameStart.Remove(ISChat.createChat)
    Events.OnGameStart.Add(new_function)
    original_fun = ISChat.createChat
    ISChat.createChat = new_function
end)
Events.OnServerCommand.Add(OnServerCommand);
Events.OnCreatePlayer.Add(OnCreatePlayer);
Events.OnWeaponHitCharacter.Add(OnWeaponHitCharacter);
-- Events.OnCharacterDeath.Add(OnCharacterDeath)
Events.OnPlayerDeath.Add(onPlayerDead);
-- Events.EveryTenMinutes.Add(updateWeekEvent);
