local parser = {}

parser.Read = function(filename, node, world)
    local data = require(filename:gsub('%.lua', ''))
    if data.defaultReward then
        node.defaultReward = data.defaultReward
    end
    local startingPos = nil
    local worldTable = {}
    for ry, row in ipairs(data.world) do
        local nodeRow = {}
        for rx, nodeStr in ipairs(row) do
            local symbol, value = nodeStr:match('([%a]):([%-%d]+)')
            symbol = symbol or nodeStr:match('([%a ])')
            if symbol == ' ' then symbol = 'R' end
            if symbol == 'S' then
                assert(not startingPos, 'More than one starting position (\'S\') in the world')
                startingPos = {rx, #data.world - ry + 1}
                symbol = 'R'
            end
            nodeRow[#nodeRow+1] = node[symbol](tonumber(value))
        end
        worldTable[#worldTable+1] = nodeRow
    end
    local newWorld = world.New(worldTable, data)
    if startingPos then
        newWorld:SetStartingPos(startingPos)
    end
    io.write('\n' .. 'WCZYTANO "' .. filename .. '" -> SWIAT (' .. tostring(newWorld) .. ')\n')
    return newWorld
end

return parser