
require "Chat/ISChat"
local ChatSystem = {};

function ChatSystem.addLineToChat(message, color, username, options,tabId)
    if type(options) ~= "table" then
        options = {
            showTime = false,
            serverAlert = false,
            showAuthor = false,
        };
    end

    if type(color) ~= "string" then
        color = "<RGB:181,53,53>";
    end

    if options.showTime then
		local dateStamp = Calendar.getInstance():getTime();
		local dateFormat = SimpleDateFormat.new("H:mm");
		if dateStamp and dateFormat then
			message = color .. "[" .. tostring(dateFormat:format(dateStamp) or "N/A") .. "]  " .. message;
		end
	else
		message = color .. message;
	end

    local msg = {
		getText = function(_)
			return message;
		end,
		getTextWithPrefix = function(_)
			return message;
		end,
		isServerAlert = function(_)
			return options.serverAlert;
		end,
		isShowAuthor = function(_)
			return options.showAuthor;
		end,
		getAuthor = function(_)
			return tostring(username);
		end,
		setShouldAttractZombies = function(_)
			return false
		end,
		setOverHeadSpeech = function(_)
			return false
		end,
		getTextColor =function (_)
			return Color(181,53,53)		
		end,
		setTextColor = function (_)
			return Color(181,53,53)		
		end
	};

	if not ISChat.instance then return; end;
	if not ISChat.instance.chatText then return; end;
	if tabId == nil then
		tabId = 0;
	end
	ISChat.addLineInChat(msg, tabId);
end

return ChatSystem;
