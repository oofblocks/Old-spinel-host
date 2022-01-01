return {
    Name = "purge";
    Aliases = {"bulkdelete"};

    Description = "Bulk deletes the specified amount of messages.";

    ExpectedArgs = "<amount>";

    MinArgs = 1;
    MaxArgs = -1;

    Callback = function(message, args, client, discordia)
        local member = message.member
        if member:hasPermission(message.channel, "manageMessages") then
            local amount = args[2]
            if amount and tonumber(amount) ~= nil then
                amount = tonumber(amount)
                if amount < 1 then
                    amount = 1
                elseif amount > 100 then
                    amount = 100
                end
    
                local messages = message.channel:getMessages(amount)
                message.channel:bulkDelete(messages)
                return message.channel:send(string.format("Successfully purged %s messages from <#%s>", #messages, message.channel.id))
            else
                return message.channel:send {
                    content = "Invalid amount.",
                    reference = {
                      message = message,
                      mention = true,
                    }
                  }
            end
        end
        message.channel:send {
            content = "You do not have permission to use this command!",
            reference = {
              message = message,
              mention = true,
            }
          }
    end
}