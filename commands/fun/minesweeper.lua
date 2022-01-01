local currentGames = {}

return {
    Name = "minesweeper";
    Aliases = {"ms"};

    Description = "Play a game of minesweeper.";

    ExpectedArgs = "<minePercentage>";

    MinArgs = -1;
    MaxArgs = -1;

    Callback = function(message, args, client, discordia)
        local player = message.author
        if currentGames[player.id] then 
            return message.channel:send {
                content = "A game is already active!",
                reference = {
                  message = message,
                  mention = true,
                }
              }
        end

        currentGames[player.id] = {}

        local function getPos(i)
            local y=math.ceil(i/5)
            local x=i-((y - 1)*5)
            return {x,y}
        end

        local function getIndex(pos)
            local x, y = pos[1], pos[2]
            return ((y - 1)*5) + x
        end

        local bombPercentage = tonumber(args[2])
        if not bombPercentage then
            bombPercentage = 20
        end

        if bombPercentage > 90 then
            bombPercentage = 90
        end

        local function defaultControls()
            local defaultButtons = discordia.Components()
            for i = 1, 25 do
                if math.random(1, 100) <= bombPercentage then
                    table.insert(currentGames[player.id], getPos(i))
                end
                defaultButtons:button {
                    id = tostring(i),
                    style = "secondary",
                    label = "?",
                    actionRow = math.ceil(i / 5),
                }
            end
            if #currentGames[player.id] == 0 then
                table.insert(currentGames[player.id], {1,1})
            end
            return defaultButtons
        end

        local vecs = {
            {1,0};
            {-1,0};
            {0,1};
            {0,-1};
            {1,1};
            {-1,1};
            {1,-1};
            {-1,-1};
        }

        local components = defaultControls()
        local cmsg = message:replyComponents("<@!" .. player.id .. ">, Your gameplay is ready:", components)

        local available = {}
        for i = 1, 25 do
            available[i] = getPos(i)
        end

        while true do
            local _, inter = cmsg:waitComponent("button")

            if inter.member == message.member then
                local buttonId = tonumber(inter.data.custom_id)
                local button = components.buttons:find(function(b)
                    return b.id == tostring(buttonId)
                end)

                local pos = getPos(buttonId)
                local mine = nil

                for _, v in pairs(currentGames[player.id]) do
                    if v[1] == pos[1] and v[2] == pos[2] then
                        mine = v
                        break
                    end
                end

                if mine then
                    print("rip bozo :alien:")
                    cmsg:setContent("You Lose!")
                    for _, poss in pairs(currentGames[player.id]) do
                        local i = getIndex(poss)
                        local mineButton = components.buttons:find(function(b)
                            return b.id == tostring(i)
                        end)

                        if mineButton then
                            mineButton:label("💥")
                            mineButton:style("danger")
                        end
                    end
                    for i = 1, 25 do
                        local btn = components.buttons:find(function(b)
                            return b.id == tostring(i)
                        end)
                        btn:disable()
                    end
                    inter:update {
                        components = components:raw()
                    }
                    currentGames[player.id] = nil
                    break
                end

                function generate(customPos)
                    if not customPos then
                        customPos = pos
                    end


                    local index = getIndex(customPos)
                    local button2 = components.buttons:find(function(b)
                        return b.id == tostring(getIndex(customPos))
                    end)    
                    if not button2 then return end

                    local adjacentBombs = 0
                    local adjacentSquares = {}

                    for i, vec in pairs(vecs) do
                        local newPos = {customPos[1] + vec[1], customPos[2] + vec[2]}
                        local i = getIndex(newPos)
                        if i > 0 and i <= 25 then
                            table.insert(adjacentSquares, getPos(i))
                            local function check()
                                for _, v in pairs(currentGames[player.id]) do
                                    if v[1] == newPos[1] and v[2] == newPos[2] then
                                        return true
                                    end
                                end
                            end
                            if check() then
                                adjacentBombs = adjacentBombs + 1
                            end
                        end
                    end

                    available[index] = nil

                    button2:label(adjacentBombs == 0 and "■" or adjacentBombs)
                    button2:disable()
                    button2:style("primary")
                end

                generate()

                local function getCount()
                    local count = 0
                    for _, v in pairs(available) do
                        if v ~= nil then
                            count = count + 1
                        end
                    end
                    return count
                end

                if getCount() == #currentGames[player.id] then
                    cmsg:setContent("You Win!")
                    for _, pos in pairs(currentGames[player.id]) do
                        local i = getIndex(pos)
                        local mineButton = components.buttons:find(function(b)
                            return b.id == tostring(i)
                        end)

                        mineButton:label("💥")
                        mineButton:style("success")
                    end
                    for i = 1, 25 do
                        local btn = components.buttons:find(function(b)
                            return b.id == tostring(i)
                        end)
                        btn:disable()
                    end
                    for _, v in pairs(available) do
                        generate(v)
                    end
                    inter:update {
                        components = components:raw()
                    }
                    currentGames[player.id] = nil
                    break
                end

                inter:update {
                    components = components:raw()
                }
        else
            inter:reply("You cannot play another persons game!", true)
        end
    end
end
}