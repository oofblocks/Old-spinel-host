local discordia = require("discordia")
local config = require("../../config.lua")
return {
    Name = "terminate";
    Aliases = {"destroy"};

    Description = "Self destruct the bot. Owner only.";

    ExpectedArgs = "";

    MinArgs = -1;
    MaxArgs = -1;

    Callback = function(message, args, client)
        if message.author.id == "771042949244518440" then
            local devServer = client:getGuild(config.devServer)
            local statusChannel = devServer:getChannel(config.statusChannel)

            statusChannel:send{
                embed = {
                    fields = {
                        {name = "Bot Offline", value = os.date()}
                    };
                    color = discordia.Color.fromRGB(255,0,0).value
                }
            }
            error(string.format("Shutdown at %s", os.date()))
        end
    end
}