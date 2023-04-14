require "Chat/ISChat"
require "pl.pretty"

local thisPlayer = nil;
local thisModData = nil;

local idSave = "testSave";

local ChatSystem = require("ChatSystem");

local function testDeath()
    print("YEEAH!!! zombie died");
    ChatSystem.addLineToChat("YEEAH!!! zombie died", "<RGB:1,1,1>");
end

local function onMessage(chatMessage, tabId)
    local msg = chatMessage:getText();
    print("LOG : PKC: onMessage=" .. msg);
end

local function tempSave()
    print("-------------------------SAVING----------------------------------");
    local writeData = getModFileWriter("PKC", "Data/PKCdata-" .. idSave .. ".txt", true, false);
    writeData:write("===DON'T EDIT THIS FILE===" .. "\n");
    writeData:write(tostring(thisPlayer:getModData().PKCModData.pvpKills) .. "\n");
    writeData:write(tostring(thisPlayer:getModData().PKCModData.pvpPoints) .. "\n");
    writeData:write(tostring(thisPlayer:getModData().PKCModData.pvpTK) .. "\n");
    writeData:write(tostring(thisPlayer:getModData().PKCModData.week) .. "\n");
    

    local tbl = thisPlayer:getModData().PKCModData.weekDeaths;

    if tbl ~= nil then
        for k, v in pairs(tbl) do
            writeData:write(k .. " %%% " .. tostring(v) .. "\n");
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
    local writeData = getModFileWriter("PKC", "Data/PKCdata-" .. idSave .. ".txt", true, false);
    writeData:write("");
    writeData:close();
end

local function readFile()
    print("-------------------------READING FILE---------------------------------");
    local readData = getModFileReader("PKC", "Data/PKCdata-" .. idSave .. ".txt", false);
    if readData ~= nil then
        print("-------------------------1---------------------------------");
        if readData:readLine() ~= "===DON'T EDIT THIS FILE===" then
            print("LOG : PKC: ERROR: File is corrupted");
            return;
        end
        print("-------------------------2---------------------------------");
        thisPlayer:getModData().PKCModData = {};
        print("-------------------------3---------------------------------");
        thisPlayer:getModData().PKCModData.pvpKills = readData:readLine();
        print("-------------------------4---------------------------------");
        thisPlayer:getModData().PKCModData.pvpPoints = readData:readLine();
        print("-------------------------5---------------------------------");
        thisPlayer:getModData().PKCModData.pvpTK = readData:readLine();
        print("-------------------------6---------------------------------");
        thisPlayer:getModData().PKCModData.week = readData:readLine();

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
                print("LOG : PKC: tblTest[" .. tostring(tbl[1]) .. "] = " .. tostring(tbl[2]) );
            end
            print("-------------------------12---------------------------------");
            line = readData:readLine();
        end
        deleteTempFile();
    else
        print("-------------------------FILE EMPTY---------------------------------");
        thisPlayer:getModData().PKCModData = {};
    end
    print("-------------------------13---------------------------------");
    readData:close();
    print("-------------------------READING FILE ENDDDD---------------------------------");
end

local function OnCharacterDeath(character)
    
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
            -- print("-------------------------READING----------------------------------");
            -- local tblTest = {}
            -- local readData = getModFileReader("PKC", "Data/PKCdata-" .. idSave .. ".txt",false);
            -- if readData ~= nil then
            --     if readData:readLine() ~= "===DON'T EDIT THIS FILE===" then
            --         print("LOG : PKC: ERROR: File is corrupted");
            --         return;
            --     end
            --     tblTest[1] = readData:readLine();
            --     tblTest[2] = readData:readLine();
            --     tblTest[3] = readData:readLine();
            --     tblTest[4] = readData:readLine();

            --     local line = readData:readLine();
            --     while line ~= nil do
            --         local tbl = line:split("%%%");
            --         if tbl[1] ~= nil then
            --             tblTest[tbl[1]] = tonumber(tbl[2]);
            --             print("LOG : PKC: tblTest[" .. tostring(tbl[1]) .. "] = " .. tostring(tblTest[tbl[1]]));
            --         end
            --         line = readData:readLine();
            --     end
            --     readData:close();
            -- end
            -- local tblTest = {diego = 1, arkn = 3, lge = 2};
            -- local tblTest2 = { 1,  3,  2};

            -- local writeData = getModFileWriter("PKC", "Data/PKCdata-" .. idSave .. ".txt", true, false);
            -- writeData:write("===DON'T EDIT THIS FILE===" .. "\n");
            -- writeData:write(tostring(thisPlayer:getModData().PKCModData.pvpKills) .. "\n");
            -- writeData:write(tostring(thisPlayer:getModData().PKCModData.pvpPoints) .. "\n");
            -- writeData:write(tostring(thisPlayer:getModData().PKCModData.pvpTK) .. "\n");
            -- writeData:write(tostring(thisPlayer:getModData().PKCModData.week) .. "\n");

            -- for key, numWeek in pairs(tblTest)  do
            --     writeData:write(tostring(key) .. " %%% " .. tostring(numWeek) .. "\n");
            -- end
            -- writeData:close();

            -- print("-------------------------TEST NAME KEY----------------------------------");
            -- local args = {
            --     victim = "[LGe] Arkn H2O"
            -- };

            -- -- thisPlayer:getModData().PKCModData.weekDeaths[args.victim] = 1;
            -- local tbl = thisPlayer:getModData().PKCModData
            -- local tbl22 = getPlayer():getModData().PKCModData
            -- print("tbl = " .. tostring(tbl));
            -- print("tbl22 = " .. tostring(tbl22));
            -- print("tbl.weekDeaths = " .. tostring(tbl.weekDeaths));
            -- print("tbl22.weekDeaths= " .. tostring(tbl22.weekDeaths));

            -- if tbl.weekDeaths[args.victim] == nil then
            --     print("-------------------------NOT EXIST----------------------------------");
            -- else
            --     print("-------------------------EXIST----------------------------------");
            -- end
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
            print("LOG : PKC: attacek=" .. args.attacker);
            print("LOG : PKC: player=" .. args.victim);
            local tbl = thisPlayer:getModData().PKCModData

            if tbl.weekDeaths[args.victim] == nil then
                print("-------------------------KILL COUNT FIRST TIME----------------------------------");
                thisPlayer:getModData().PKCModData.weekDeaths[args.victim] = thisPlayer:getModData().PKCModData.week;
                ChatSystem.addLineToChat("Punto por matar a " .. args.victim, "<RGB:1,1,1>");
            elseif tbl.weekDeaths[args.victim] < tbl.week then
                print("-------------------------KILL COUNT----------------------------------");
                thisPlayer:getModData().PKCModData.weekDeaths[args.victim] = thisPlayer:getModData().PKCModData.week;
                ChatSystem.addLineToChat("Punto por matar a " .. args.victim, "<RGB:1,1,1>");
            else
                print("-------------------------KILL COUNT NOT ADDED----------------------------------");
                ChatSystem.addLineToChat(args.victim .. " NO da mas puntos para la semana " ..
                                             thisPlayer:getModData().PKCModData.week, "<RGB:1,1,1>");
            end
        end
    end
end

local function OnSave()
    print("-------------------------SAVING----------------------------------");
    local writeData = getModFileWriter("PKC", "Data/PKCdata.txt", true, false);
    writeData:write("Hello World");
    writeData:close();
end

-- Events.OnSave.Add(OnSave);
Events.OnServerCommand.Add(OnServerCommand);
Events.OnCreatePlayer.Add(OnCreatePlayer);
-- Events.OnWeaponHitCharacter.Add(OnWeaponHitCharacter);
-- Events.OnCharacterDeath.Add(OnCharacterDeath)
Events.OnPlayerDeath.Add(onPlayerDead);
-- Events.OnZombieDead.Add(testDeath);
-- Events.OnAddMessage.Add(onMessage);
