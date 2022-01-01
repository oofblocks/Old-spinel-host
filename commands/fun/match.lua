local currentGames = {}

return {
    Name = "match";
    Aliases = {"match", "matching"};

    Description = "Play a game of matching.";
    
    ExpectedArgs = "";

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

        local emojis = {"💎"; "🍉"; "❤️"; "🔥"; "💯"; "🍌"; "🐶"; "🐬"; "🎉"; "😍"; "🐱"; "👽"; 
        "💩"; "🏴‍☠️"; "🍆"; "🍕"; "🗿"; "🦍"; "🎲"; "☢️"; "⛏️"; "♟️"; "🐷"; "🎅"}

        for i = 1, 12 do
            table.remove(emojis, math.random(1, #emojis))
        end

        local usedNums = {}
        local function getNum()
            local chosenNumber = math.random(1,24)
            if usedNums[chosenNumber] then
                repeat chosenNumber = math.random(1,24)
                until not usedNums[chosenNumber]
            end 
            usedNums[chosenNumber] = true
            return chosenNumber
        end
        for _, v in pairs(emojis) do
            local num1 = getNum()
            local num2 = getNum()
            currentGames[player.id][v] = {num1, num2}
        end

        local function defaultControls()
            local defaultButtons = discordia.Components()
            for i = 1, 24 do
                defaultButtons:button {
                    id = tostring(i),
                    style = "secondary",
                    label = "?",
                    actionRow = math.ceil(i / 5),
                }
            end
            defaultButtons:button {
                id = "abort",
                style = "danger",
                label = "Abort",
                actionRow = 5,
            }
            return defaultButtons
        end

        local function findFromIndex(i)
            for emoji, positions in pairs(currentGames[player.id]) do
                local pos = nil
                for _, v in pairs(positions) do
                    if v == i then
                        pos = true
                        break
                    end
                end
                if pos then
                    return emoji
                end
            end
        end

        local function wait(a) 
            local sec = tonumber(os.clock() + a); 
            while (os.clock() < sec) do 
            end 
        end

        local matched = {}
        local selected = nil
        local pos = nil

        local components = defaultControls()
        local cmsg = message:replyComponents("<@!" .. player.id .. ">, Your gameplay is ready:", components)

        while true do
            local _, inter = cmsg:waitComponent("button")
            if inter.member == message.member then
                local buttonId = tonumber(inter.data.custom_id)

                if inter.data.custom_id == "abort" then
                    local abortMessage = inter:reply("Aborting...", true)
                    cmsg:setContent("Game aborted.")
                    currentGames[player.id] = nil
                    for i = 1, 24 do
                        local button = components.buttons:find(function(b)
                            return b.id == tostring(i)
                        end)
                        button:disable()
                    end
                    break
                end

                local button = components.buttons:find(function(b)
                    return b.id == tostring(buttonId)
                end)

                if not selected then
                    local emoji = findFromIndex(buttonId)
                    if emoji then
                        button:label(emoji)
                            :style("primary")
                            :disable()
                    end
                    selected = emoji
                    pos = buttonId
                else
                    local emoji = findFromIndex(buttonId)
                    if emoji == selected then
                        local emojiPositions = currentGames[player.id][emoji]
                        for i = 1, 2 do
                            local buttonId2 = emojiPositions[i]
                            local button2 = components.buttons:find(function(b)
                                return b.id == tostring(buttonId2)
                            end)
                            button2:label(emoji)
                                :style("success")
                                :disable()
                        end
                        table.insert(matched, emojiPositions)
                    else
                        local selectedButton = components.buttons:find(function(b)
                            return b.id == tostring(pos)
                        end)
                        selectedButton:style("danger")
                            :disable()
                        button:style("danger")
                            :label(findFromIndex(buttonId))
                            :disable()
                        for i = 1, 24 do
                            local button2 = components.buttons:find(function(b)
                                return b.id == tostring(i)
                            end)
                            button2:disable()
                        end
                        local abort = components.buttons:find(function(b)
                            return b.id == "abort"
                        end)
                        abort:disable()
                        inter:update {
                            components = components:raw()
                        }
                        wait(1)
                        selectedButton:label("?")
                            :style("secondary")
                            :enable()
                        button:label("?")
                            :style("secondary")
                            :enable()
                        abort:enable()
                        for i = 1, 24 do
                            local yes = true
                            for _, v in pairs(matched) do
                                for _, pos in pairs(v) do
                                    if pos == i then
                                        yes = false
                                        break
                                    end
                                end
                            end
                            if yes then
                                local button2 = components.buttons:find(function(b)
                                    return b.id == tostring(i)
                                end)
                                button2:enable()
                            end
                        end
                    end
                    pos = nil
                    selected = nil
                end
                if #matched == 12 then
                    cmsg:setContent("You Win!")
                    for i = 1, 24 do
                        local button2 = components.buttons:find(function(b)
                            return b.id == tostring(i)
                        end)
                        button2:style("success")
                    end
                    local abort = components.buttons:find(function(b)
                        return b.id == "abort"
                    end)
                    abort:disable()
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