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

local function updateWeekEvent()
    local calendar = Calendar.getInstance();
    local dayWeek = calendar:get(Calendar.DAY_OF_WEEK);
    local weekYear = calendar:get(Calendar.WEEK_OF_YEAR);
    local playerWeek =  tonumber(thisPlayer:getModData().PKCModData.week);

    if weekYear > playerWeek then
        thisPlayer:getModData().PKCModData.week = weekYear;
        print("LOG : PKC: week updated");
    end
end

function PKCMain.updateUI()
    print("LOG : PKC: updateUI");
    local zText = "Kills: " .. tostring(thisPlayer:getModData().PKCModData.pvpKills) .. " <LINE> Points: " ..
                      tostring(thisPlayer:getModData().PKCModData.pvpPoints) .. " <LINE> TK: " ..
                      tostring(thisPlayer:getModData().PKCModData.pvpTK);
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

local function chatPrintStats(tabId)
    print("LOG : PKC: chatPrintStats");
    local msg = "Kills: " .. tostring(thisPlayer:getModData().PKCModData.pvpKills) .. " | Points: " ..
                    tostring(thisPlayer:getModData().PKCModData.pvpPoints) .. " | TK: " ..
                    tostring(thisPlayer:getModData().PKCModData.pvpTK);
    printMsg(msg, tabId);
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
            chatPrintStats(tabId);
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

local function tempSave()
    print("-------------------------SAVING----------------------------------");
    local writeData = getModFileWriter("PKC", "Data/PKCdata-" .. thisPlayer:getUsername() .. ".txt", true, false);
    writeData:write("===DON'T EDIT THIS FILE===" .. "\n");
    writeData:write(tonumber(thisPlayer:getModData().PKCModData.pvpKills) .. "\n");
    writeData:write(tonumber(thisPlayer:getModData().PKCModData.pvpPoints) .. "\n");
    writeData:write(tonumber(thisPlayer:getModData().PKCModData.pvpTK) .. "\n");
    writeData:write(tonumber(thisPlayer:getModData().PKCModData.week) .. "\n");

    local tbl = thisPlayer:getModData().PKCModData.weekDeaths;

    if tbl ~= nil then
        for k, v in pairs(tbl) do
            writeData:write(k .. " %%% " .. tonumber(v) .. "\n");
        end
    end

    writeData:close();
end

local function onPlayerDead(player)
    if thisPlayer:getUsername() == player:getUsername() then
        print("LOG : PKC: onPlayerDead=" .. tostring(player:getUsername()));
        thisModData = thisPlayer:getModData().PKCModData;
        tempSave();
    end
end

local function deleteTempFile()
    local writeData = getModFileWriter("PKC", "Data/PKCdata-" .. thisPlayer:getUsername() .. ".txt", true, false);
    writeData:write("");
    writeData:close();
end

local function readFile()
    print("-------------------------READING FILE---------------------------------");
    local readData = getModFileReader("PKC", "Data/PKCdata-" .. thisPlayer:getUsername() .. ".txt", false);
    if readData ~= nil then
        print("-------------------------1---------------------------------");
        if readData:readLine() ~= "===DON'T EDIT THIS FILE===" then
            print("LOG : PKC: ERROR: File is corrupted");
            return;
        end
        print("-------------------------2---------------------------------");
        thisPlayer:getModData().PKCModData = {};
        print("-------------------------3---------------------------------");
        thisPlayer:getModData().PKCModData.pvpKills = tonumber(readData:readLine());
        print("-------------------------4---------------------------------");
        thisPlayer:getModData().PKCModData.pvpPoints = tonumber(readData:readLine());
        print("-------------------------5---------------------------------");
        thisPlayer:getModData().PKCModData.pvpTK = tonumber(readData:readLine());
        print("-------------------------6---------------------------------");
        thisPlayer:getModData().PKCModData.week = tonumber(readData:readLine());

        thisPlayer:getModData().PKCModData.weekDeaths = {};
        local line = readData:readLine();
        print("-------------------------7---------------------------------");
        while line ~= nil do
            print("-------------------------8---------------------------------");
            local tbl = line:split(" %%% ");
            print("-------------------------9---------------------------------");
            if tbl[1] ~= nil then
                print("-------------------------10---------------------------------");
                thisPlayer:getModData().PKCModData.weekDeaths[tbl[1]] = tonumber(tbl[2]);
                print("-------------------------11---------------------------------");
                print("LOG : PKC: tblTest[" .. tostring(tbl[1]) .. "] = " .. tostring(tbl[2]));
            end
            print("-------------------------12---------------------------------");
            line = readData:readLine();
        end
        readData:close();
        print("-------------------------READING FILE ENDDDD---------------------------------");
        deleteTempFile();
    else
        print("-------------------------FILE EMPTY---------------------------------");
        thisPlayer:getModData().PKCModData = {};
    end
    print("-------------------------13---------------------------------");
end

local function playerCreateModData(player)
    if not player then
        return
    end
    print("-------------------------CREATE MOD DATA----------------------------------");
    if thisModData ~= nil then
        print("-----------thisModData------------------")
        player:getModData().PKCModData = thisModData;
    end
    if player:getModData().PKCModData == nil then

        readFile();

        if player:getModData().PKCModData == nil then
            print("-----------PKCModData------------------")
            player:getModData().PKCModData = {};
        else
            print("-----------SCRIPT DATA------------------")
        end
    end
    if player:getModData().PKCModData.pvpKills == nil then
        print("-----------pvpKills------------------")
        player:getModData().PKCModData.pvpKills = 0;
    end
    if player:getModData().PKCModData.pvpPoints == nil then
        print("-----------pvpPoints------------------")
        player:getModData().PKCModData.pvpPoints = 0;
    end
    if player:getModData().PKCModData.pvpTK == nil then
        print("-----------pvpTK------------------")
        player:getModData().PKCModData.pvpTK = 0;
    end
    if player:getModData().PKCModData.weekDeaths == nil then
        print("-----------weekDeaths------------------")
        player:getModData().PKCModData.weekDeaths = {};
    end
    if player:getModData().PKCModData.week == nil then
        print("-----------week------------------")
        player:getModData().PKCModData.week = 1;
    end
    updateWeekEvent();
end

local function OnCreatePlayer(playerIndex, player)
    print("-------------------------CREATE PLAYER----------------------------------");
    thisPlayer = player
    print("LOG : thisPlayer=" .. tostring(thisPlayer:getUsername()));
    playerCreateModData(player);
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
            local dateFormat = SimpleDateFormat.new("H:mm");
            print("LOG : PKC: isnewgame= " .. tostring(getGameTime()));

        end
    end
end

local function sumEventPoints(args)
    thisPlayer:getModData().PKCModData.pvpKills = tonumber(thisPlayer:getModData().PKCModData.pvpKills) + 1;
    thisPlayer:getModData().PKCModData.pvpPoints = tonumber(thisPlayer:getModData().PKCModData.pvpPoints) + 1;
    thisPlayer:getModData().PKCModData.weekDeaths[args.victim] = tonumber(thisPlayer:getModData().PKCModData.week);
    ChatSystem.addLineToChat("Punto por matar a " .. args.victim);
end

local function getStats()
    local msg = "Kills: " .. tostring(thisPlayer:getModData().PKCModData.pvpKills) .. " | Points: " ..
                    tostring(thisPlayer:getModData().PKCModData.pvpPoints) .. " | TK: " ..
                    tostring(thisPlayer:getModData().PKCModData.pvpTK);
    return msg;
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
            local tbl = thisPlayer:getModData().PKCModData

            if tbl.weekDeaths[args.victim] == nil then
                print("-------------------------KILL COUNT FIRST TIME----------------------------------");
                sumEventPoints(args);
            elseif tonumber(tbl.weekDeaths[args.victim]) < tonumber(tbl.week) then
                print("-------------------------KILL COUNT----------------------------------");
                sumEventPoints(args);
            else
                print("--------------------sss-----KILL COUNT NOT ADDED----------------------------------");
                local tempWeek = tonumber(thisPlayer:getModData().PKCModData.week) - weekOffset;
                ChatSystem.addLineToChat(args.victim .. " NO da mas puntos para la semana " .. tempWeek, "<RGB:1,1,1>");
            end
            thisPlayer:getModData().PKCModData.pvpTK = tonumber(thisPlayer:getModData().PKCModData.pvpTK) + 1;
            PKCMain.updateUI();
        end
    elseif command == "getStats" then
        print("-------------------------GET STATS----------------------------------");
        args.stats = getStats();
        args.player = thisPlayer:getUsername();
        sendClientCommand(thisPlayer, "PKC", "broadcast", args);
    elseif command == "broadcast" then
        print("-------------------------BROADCAST----------------------------------");
        if args.admin == thisPlayer:getUsername() then
            ChatSystem.addLineToChat(args.player .. " = " .. args.stats, "<RGB:1,1,1>", nil, nil, adminTabId);
        end
    end
end

local function EveryOneMinute()
	-- Your code here
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
Events.EveryTenMinutes.Add(updateWeekEvent);
