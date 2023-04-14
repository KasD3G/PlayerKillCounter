-- Esta funcion no puede hacer uso de print en la consola del servidor
local function OnClientCommand(module, command, player, args)

    if module ~= "PKC" then
        return;
    end

    if command == "PlayerHit" then
        args['player'] = player:getUsername();
        sendServerCommand("PKC", "PlayerHit", args);
    end

end

local function OnSave()
    print("LOG_SERVER : PKC: OnSave");
    local writeData = getModFileWriter("PKC", "PKCdataServer.txt", true, false);
    writeData:write("Hello World SERVER");
    writeData:close();
end

local function OnCharacterDeath(character)
    if not character:isZombie() then
        print("-------------------------OnCharacterDeath----------------------------------")

        local victim = character:getUsername();

        if character:getAttackedBy():isZombie() then
            print("LOG : PKC: " .. victim .. " was killed by a zombie");
        else
            local attacker = character:getAttackedBy():getUsername();
            print("LOG : PKC: " .. victim .. " was killed by " .. attacker);
            sendServerCommand("PKC", "PlayerDeath", {victim=victim, attacker=attacker});
        end

    end
end

local function onPlayerDeath(player)
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

Events.OnPlayerDeath.Add(onPlayerDeath);
Events.OnClientCommand.Add(OnClientCommand);
-- Events.OnCharacterDeath.Add(OnCharacterDeath);
