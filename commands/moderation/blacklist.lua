local json = require("json")

return {
    Name = "blacklist";
    Aliases = {"bl"};

    Description = "Blacklist a channel from command usage.";

    ExpectedArgs = "<textChannel>";

    MinArgs = 1;
    MaxArgs = -1;

    Callback = function(message, args, client)
        if not message.member:hasPermission(message.channel, "manageChannels") then
            return message.channel:send {
                content = "You do not have permission to use this command!",
                reference = {
                  message = message,
                  mention = true,
                }
            }
        end

        local channelId = message.mentionedChannels[1]

        if channelId then
            channelId = channelId[1]

            local channel = client:getChannel(channelId)
            if not channel.guildId == message.guild.id then 
                return message.channel:send {
                    content = "Invalid channel.",
                    reference = {
                      message = message,
                      mention = true,
                    }
                }
            end

            local open = io.open("./json/blacklist.json", "r")
            local blacklist = json.parse(open:read())
            open:close()

            if blacklist[channelId] then
                return message.channel:send {
                    content = "This channel is already blacklisted!\nUse `&whitelist <textChannel>` to whitelist it.",
                    reference = {
                      message = message,
                      mention = true,
                    }
                }
            end
            blacklist[channelId] = true

            open = io.open("./json/blacklist.json", "w")
            open:write(json.stringify(blacklist))
            open:close()

            return message.channel:send {
                content = string.format("Successfully blacklisted <#%s>.", channelId);
                reference = {
                  message = message,
                  mention = true,
                }
            }
        end

        message.channel:send {
            content = "Invalid channel.",
            reference = {
              message = message,
              mention = true,
            }
          }

    end
}