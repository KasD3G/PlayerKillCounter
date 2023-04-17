if isClient() then
    return;
end

local weekOffset = 15;
local week = 1;

local function PkcModData()
    print("-----OnInitGlobalModData------")
    if not ModData.exists("PKCData") then
        print("Creating PKC ModData");
        local t = ModData.create("PKCData");
        t.key = "PKCData";
        local dateStamp = Calendar.getInstance():getTime();
        local dateFormat = SimpleDateFormat.new("dd/MM/yyyy HH:mm:ss");
        t.creationDate = tostring(dateFormat:format(dateStamp) or "N/A");
        t.data = {};
    end
end

local function WeekEvent()
    local calendar = Calendar.getInstance();
    local weekYear = calendar:get(Calendar.WEEK_OF_YEAR);

    return weekYear
end

local function sumEventPoints(playerData, victim)
    playerData.weekDeaths[victim] = WeekEvent();
    playerData.pvpPoints = playerData.pvpPoints + 1;
    playerData.pvpKills = playerData.pvpKills + 1;

    return playerData;
end

local function setModDataPlayer(steamID, player, victim)
    local tbl = ModData.get("PKCData");
    local msg = "";
    local tempWeek = nil

    if tbl["data"] == nil then
        tbl.data = {};
        msg = msg .. " Creating data table";
    end

    if tbl.data[steamID] == nil then
        tbl.data[steamID] = {};
        msg = msg .. " Creating steamID: " .. steamID;
    end

    local steamData = tbl.data[steamID];
    if steamData[player] == nil then
        tbl.data[steamID][player] = {};
        msg = msg .. " Creating player: " .. player;
    end

    local playerData = steamData[player];

    if playerData["pvpKills"] == nil then
        tbl.data[steamID][player]["pvpKills"] = 0;
        msg = msg .. " Creating pvpKills";
    end

    if playerData["pvpPoints"] == nil then
        tbl.data[steamID][player]["pvpPoints"] = 0;
        msg = msg .. " Creating pvpPoints";
    end

    if playerData["pvpTK"] == nil then
        tbl.data[steamID][player]["pvpTK"] = 0;
        msg = msg .. " Creating pvpTK";
    end

    if playerData["weekDeaths"] == nil then
        tbl.data[steamID][player]["weekDeaths"] = {};
        msg = msg .. " Creating weekDeaths";
    end

    local tblWeekDeaths = playerData["weekDeaths"];

    if victim ~= nil then

        if tblWeekDeaths[victim] == nil then
            tbl.data[steamID][player] = sumEventPoints(tbl.data[steamID][player], victim);
            msg = " KILL COUNT FIRST TIME"
        elseif tblWeekDeaths[victim] < WeekEvent() then
            tbl.data[steamID][player] = sumEventPoints(tbl.data[steamID][player], victim);
            msg = " KILL COUNT"
        else
            tempWeek = WeekEvent() - weekOffset;
            msg = " KILL COUNT NOD ADDED"
        end
        tbl.data[steamID][player].pvpTK = tbl.data[steamID][player].pvpTK + 1;
    end

    return {
        msg = msg,
        tempWeek = tempWeek
    };
end

local function getPlayerData(steamID, player)
    local tbl = ModData.get("PKCData");

    if tbl.data[steamID] == nil then
        return nil;
    end

    if tbl.data[steamID][player] == nil then
        return nil;
    end

    return tbl.data[steamID][player];
end

local function getAllPlayersData()
    local tbl = ModData.get("PKCData");
    local msgData = nil;

    for steamID, steamData in ipairs(tbl.data) do
        for player, dataPlayer in ipairs(steamData) do
            local msg = tostring(player) .. " : Kills: " .. tostring(dataPlayer.pvpKills) .. " | Points: " ..
                            tostring(dataPlayer.pvpPoints) .. " | TK: " .. tostring(dataPlayer.pvpTK);
            if msgData == nil then
                msgData = msg;
            else
                msgData = msgData .. "<LINE>" .. msg;
            end
        end
    end

    return msgData;
end

local function OnClientCommand(module, command, player, args)

    if module ~= "PKC" then
        return;
    end

    if command == "admin" then
        sendServerCommand("PKC", "getStats", {
            admin = player:getUsername(),
            msg = getAllPlayersData()
        });
    elseif command == "createPlayer" then
        local steamID = player:getSteamID();
        local playerName = player:getUsername();
        local data = setModDataPlayer(steamID, playerName, nil);

        sendServerCommand("PKC", "createPlayer", {
            player = playerName,
            msg = data.msg,
            tempWeek = data.tempWeek
        });
    elseif command == "broadcast" then
        -- sendServerCommand("PKC", "broadcast", args);
    elseif command == "updateUI" then
        sendServerCommand("PKC", "updateUI", {
            playerData = getPlayerData(player:getSteamID(), player:getUsername()),
            player = player:getUsername()
        });
    elseif command == "chatPrintStats" then
        sendServerCommand("PKC", "chatPrintStats", {
            playerData = getPlayerData(player:getSteamID(), player:getUsername()),
            player = player:getUsername()
        });
    end

end

local function OnCharacterDeath(player)
    if not player:isZombie() then
        print("-------------------------OnCharacterDeath----------------------------------")
        print("LOG_SERVER : PKC : player " .. tostring(player:getUsername()));
        print("LOG_SERVER : PKC : attacker " .. tostring(player:getAttackedBy()));
        print("LOG_SERVER : PKC : isOnFire " .. tostring(player:isOnFire()));
        local victim = player:getUsername();

        if player:getAttackedBy() == nil then
            print("LOG : PKC: " .. victim .. " es un tonto y se ha suicidado");
        elseif player:getAttackedBy():isZombie() then
            print("LOG : PKC: " .. victim .. " was killed by a zombie");
        else
            local attacker = player:getAttackedBy():getUsername();
            print("LOG : PKC: " .. victim .. " was killed by " .. attacker);

            local data = setModDataPlayer(player:getSteamID(), attacker, victim);
            sendServerCommand("PKC", "PlayerDeath", {
                msg = data.msg,
                tempWeek = data.tempWeek,
                victim = victim,
                attacker = attacker
            });
        end

    end
end

Events.OnInitGlobalModData.Add(PkcModData);
Events.OnCharacterDeath.Add(OnCharacterDeath);
Events.OnClientCommand.Add(OnClientCommand);
