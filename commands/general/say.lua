local currentGames = {}

return {
    Name = "say";
    Aliases = {"speak", "talk"};

    Description = "This is actually the first command ever created for the bot. Makes the bot say whatever you want it to say.";

    ExpectedArgs = "<text>";

    MinArgs = 1;
    MaxArgs = -1;

    Callback = function(message, args, client)
        local text = ""
        for k, v in pairs(args) do
            if k ~= 1 then
                text = text .. v .. " "
            end
        end
        message:reply(text)
    end
}