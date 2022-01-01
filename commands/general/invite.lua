return {
    Name = "invite";
    Aliases = {"inv"};

    Description = "Add the bot to your server or recieve an invite to the dev server.";

    ExpectedArgs = "<discord?>";

    MinArgs = -1;
    MaxArgs = -1;

    Callback = function(message, args, client, discordia)
        local inviteButtons = discordia.Components() 

        if args[2] and args[2]:lower() == "discord" then
            inviteButtons:button { 
                label = "Join the discord server!",
                style = "link",
                url = "https://discord.gg/QRfFggdDp7"
            }
        else
            inviteButtons:button { 
                label = "Add the bot to your server!",
                style = "link",
                url = "https://discord.com/api/oauth2/authorize?client_id=914604704124796958&permissions=416611696374&scope=bot"
            }
        end

        message:replyComponents("fard", inviteButtons)

    end
}