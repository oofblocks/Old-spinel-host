local fs = require("fs")
return function()
    local h = {}
        for folder in fs.scandirSync("./commands") do
            for file in fs.scandirSync("./commands/" .. folder) do
                local cmd = require("./commands/" .. folder .. "/" .. file)
                h[cmd.Name] = {c=folder;d=cmd}
            end
        end
    return h
end