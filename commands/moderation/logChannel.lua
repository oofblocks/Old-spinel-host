local json = require("json")

return {
    Name = "logchannel";
    Aliases = {"loggingchannel"};

    Description = "Set the logging channel of a guild. There can only be one logging channel per guild.";

    ExpectedArgs = "<channelId>";

    MinArgs = 1;
    MaxArgs = -1;

    Callback = function(message, args, client, discordia)
        if not message.member:hasPermission(message.channel, "manageMessages") then
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
            local open = io.open("./json/loggingData.json", "r")
            local parse = json.parse(open:read())
            open:close()

            local guild = message.guild

            if parse[guild.id] then
                if parse[guild.id] == channelId then
                    parse[guild.id] = nil
                    message.channel:send {
                        content = "Removed logging channel.",
                        reference = {
                          message = message,
                          mention = true,
                        }
                      }
                    open = io.open("./json/loggingData.json", "w")
                    open:write(json.stringify(parse))
                    open:close()
                    return
                end
            end

            parse[guild.id] = channelId

            open = io.open("./json/loggingData.json", "w")
            open:write(json.stringify(parse))
            open:close()

            return message.channel:send {
                content = string.format("Set <#%s> as the current logging channel for this guild.", channelId);
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