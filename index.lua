local json = require("json")
local fs = require("fs")
local config = require("./config.lua")

local discordia = require("discordia")
require("discordia-interactions")
require("discordia-components")

local client = discordia.Client()
discordia.extensions()

local commands = {}

client:on("ready", function()
    local devServer = client:getGuild(config.devServer)
    local statusChannel = devServer:getChannel(config.statusChannel)

    statusChannel:send{
        embed = {
            fields = {
                {name = "Bot Online", value = os.date()}
            };
            color = discordia.Color.fromRGB(0,255,0).value
        }
    }

    print("---------------------------------------")

    for file in fs.scandirSync("./features") do
        local feature = require("./features/" .. file)
        if feature then
            feature(client, discordia)
            print("Successfully loaded " .. file)
        else
            warn("Failed to load " .. file)
        end
    end

    print("---------------------------------------")

    client:setGame("with old spinel")
    for folder in fs.scandirSync("./commands") do
        for file in fs.scandirSync("./commands/" .. folder) do
            local command = require("./commands/" .. folder .. "/" .. file)
            if command then
                commands[command.Name] = command
                print("Successfully loaded " .. file)
            else
                warn("Failed to load " .. file)
            end
        end
    end
end)

client:on("messageCreate", function(message)
    local content = message.content
    local author = message.author

    local args = content:split(" ")

    if author.bot then return end

    local open = io.open("./json/blacklist.json", "r")
    local parse = json.parse(open:read())
    open:close()


    for k, v in pairs(commands) do

        local aliases = v.Aliases
        table.insert(aliases, k)

        for _, alias in pairs(aliases) do
            if args[1]:sub(1, #args[1]):lower() == config.prefix .. alias then

                if parse[message.channel.id] and not message.member:hasPermission(message.channel, "manageChannels") then
                    return message.channel:send {
                        content = "Commands are not allowed in this channel!\nIf you have the `Manage Channels` permission, you can bypass this.",
                        reference = {
                          message = message,
                          mention = true,
                        }
                      }
                end

                if #args - 1 < v.MinArgs or v.MaxArgs ~= -1 and #args - 1 > v.MaxArgs then
                    return message.channel:send {
                        content = "Invalid arguments! Expected arguments: `" .. config.prefix .. alias .." " .. v.ExpectedArgs .. "`",
                        reference = {
                          message = message,
                          mention = true,
                        }
                      }
                end

                print("Running " .. k)
                return v.Callback(message, args, client, discordia)
            end
        end
    end

end) 

client:run("Bot " .. config.token)