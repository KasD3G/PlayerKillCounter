if isClient() then
    return;
end

local function PkcModData()
    print("-----OnInitGlobalModData------")
    if not ModData.exists("PKCData") then
        print("Creating PKC ModData");
        local t = ModData.create("PKCData");
        t.key = "PKCData";
        local dateStamp = Calendar.getInstance():getTime();
        local dateFormat = SimpleDateFormat.new("dd/MM/yyyy HH:mm:ss");
        t.creationDate = tostring(dateFormat:format(dateStamp) or "N/A");
    end
end

local function OnClientCommand(module, command, player, args)
    
    if module ~= "PKC" then
        return;
    end

    if command == "admin" then
        sendServerCommand("PKC", "getStats", {admin=player:getUsername()});
    elseif command == "broadcast" then
        sendServerCommand("PKC", "broadcast", args);
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
            sendServerCommand("PKC", "PlayerDeath", {victim=victim, attacker=attacker});
        end

    end
end

Events.OnInitGlobalModData.Add(PkcModData);
Events.OnCharacterDeath.Add(OnCharacterDeath);
Events.OnClientCommand.Add(OnClientCommand);
