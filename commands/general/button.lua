return {
    Name = "button";
    Aliases = {"butt", "btn"};

    Description = "Creates a button. Intended for testing purposes.";

    ExpectedArgs = "<buttonText>";

    MinArgs = 1;
    MaxArgs = -1;

    Callback = function(message, args, client, discordia)

        local text = ""
        for k, v in pairs(args) do
            if k ~= 1 then
                text = text .. v .. " "
            end
        end

        if #text > 80 then
           return message.channel:send {
                content = "Text must not be greater than 80 characters!",
                reference = {
                  message = message,
                  mention = false,
                }
              }
        end

        local button = discordia.Components {
            { 
                 id = "button",
                 type = "button",
                 label = text,
                 style = "danger",
            }
        }
        local bmessage = message:replyComponents("Here is your button!", button)

        local success, inter

        while true do
            success, inter = bmessage:waitComponent("button")
            if not success then break end

            if inter.data.custom_id == "button" then

                local randomIP = ""
                for i = 1, 4 do
                    randomIP = randomIP .. tostring(math.random(1,255))
                    if i ~= 4 then
                        randomIP = randomIP .. "."
                    end
                end

                inter:reply(randomIP)
                break
            end

        end
    end
}