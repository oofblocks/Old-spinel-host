local json = require("json")

return function(client, discordia)
    local function getLoggedChannels()
        local open = io.open("./json/loggingData.json", "r")
        local parse = json.parse(open:read())
        open:close()

        return parse
    end

    local function log(data)
        if not data.guild then return end
        local loggedChannels = getLoggedChannels()
        if loggedChannels[data.guild] then
            local channel = client:getChannel(loggedChannels[data.guild])
            if channel then
                if data.channel ~= channel.id then
                    channel:send {
                        embed = {
                            title = data.header;
                            description = data.info;
                            color = discordia.Color.fromRGB(data.color[1], data.color[2], data.color[3]).value
                        }
                    }
                end
            end
        end
    end

    client:on("channelCreate", function(channel)
        log {
            guild = channel.guild.id;
            header = "Channel created";
            info = string.format("<#%s> was created at %s", channel.id, os.date());
            color = {0,255,0}
        }
    end)

    client:on("channelDelete", function(channel)
        log {
            guild = channel.guild.id;
            header = "Channel deleted";
            info = string.format("#%s was deleted at %s", channel.name, os.date());
            color = {255,0,0}
        }
    end)

    client:on("userBan", function(user, guild)
        log {
            guild = guild.id;
            header = "User banned";
            info = string.format("<@!%s> was banned at %s", user.id, os.date());
            color = {255,0,0}
        }
    end)

    client:on("userUnban", function(user, guild)
        log {
            guild = guild.id;
            header = "User unbanned";
            info = string.format("<@!%s> was unbanned at %s", user.id, os.date());
            color = {0,255,0}
        }
    end)

    client:on("memberJoin", function(member)
        log {
            guild = member.guild.id;
            header = "User joined";
            info = string.format("<@!%s> joined at %s", member.id, os.date());
            color = {0,255,0}
        }
    end)

    client:on("memberLeave", function(member)
        log {
            guild = member.guild.id;
            header = "User left";
            info = string.format("<@!%s> left at %s", member.id, os.date());
            color = {255,0,0}
        }
    end)

    client:on("roleCreate", function(role)
        log {
            guild = role.guild.id;
            header = "Role created";
            info = string.format("<@&%s> was created at %s", role.id, os.date());
            color = {0,255,0}
        }
    end)

    client:on("roleDelete", function(role)
        log {
            guild = role.guild.id;
            header = "Role deleted";
            info = string.format("@%s was deleted at %s", role.name, os.date());
            color = {255,0,0}
        }
    end)

    client:on("messageDelete", function(message)
        log {
            guild = message.guild.id;
            header = "Message deleted";
            info = string.format("Message deleted in <#%s> at %s\n\n%s", message.channel.id, os.date(), message.content);
            color = {255,0,0};
            channel = message.channel.id
        }
    end)


end