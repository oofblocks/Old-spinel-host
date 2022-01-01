local get = require("../../getCommands.lua")

return {
    Name = "help";
    Aliases = {};

    Description = "Gives a list of commands.";

    ExpectedArgs = "<category/command>";

    MinArgs = -1;
    MaxArgs = -1;

    Callback = function(message, args, client)
        local h = get()
        local categories = {}

        for _, d in pairs(h) do
            if not categories[d.c] then
                categories[d.c] = 1
            else
                categories[d.c] = categories[d.c] + 1
            end
        end

        if args[2] and categories[args[2]:lower()] then
            local fields = {}
            
            for n, d in pairs(h) do
                if d.c == args[2]:lower() then
                    local sp = ""
                    if d.d.ExpectedArgs ~= "" then
                        sp = " "
                    end
                    table.insert(fields, {
                        name = "`&" .. n .. sp .. d.d.ExpectedArgs .. "`";
                        value = d.d.Description
                    })
                end
            end
            return message.channel:send {
                    embed = {
                        title = args[2] .. " commands";
                        description = "-----------------";
                        author = {
                            name = message.author.username,
                            icon_url = message.author.avatarURL
                        };
                        fields = fields;
                    };
                reference = {
                  message = message,
                  mention = true,
                }
              }
        end

        if args[2] and h[args[2]:lower()] then
            local commandData = h[args[2]:lower()].d
            local a = ""
            for _, v in pairs(commandData.Aliases) do
                a = a .. v
                if k ~= #v - 1 then
                    a = a  .. " | "
                end
            end
            return message.channel:send {
                    embed = {
                        title = commandData.Name;
                        description = commandData.Description or "This command has no description.";
                        author = {
                            name = message.author.username,
                            icon_url = message.author.avatarURL
                        };
                        fields = {
                            {
                                name = "Usage";
                                value = "`&" .. commandData.Name .. " " .. commandData.ExpectedArgs .. "`"
                            };
                            {
                                name = "Aliases";
                                value = "`" .. a .. "`"
                            }
                        };
                },
                reference = {
                  message = message,
                  mention = true,
                }
              }
        end

        local fields = {}
        for category, amount in pairs(categories) do
            table.insert(fields, {
                name = "`" .. category .. "`";
                value = amount .. " commands in this category.";
            })
        end

        message.channel:send {
            embed = {
                title = "Command categories";
                description = "-----------------";
                fields = fields;
            },
            reference = {
              message = message,
              mention = true,
            }
          }

    end
}