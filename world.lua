require 'util'
local world = {}

local worldMeta = {
    __index = world,
    -- Indeksowanie w(x, y) i w({x, y})
    __call = function(w, ...)
        local args = {...}
        if #args == 1 then
            return w:GetNode(args[1])
        else
            return w:GetNode({args[1], args[2]})
        end
    end
}

world.New = function(worldTable, params)
    params = params or {}
    local newWorld = setmetatable({__type = 'world'}, worldMeta)
    newWorld.size = {#worldTable[1], #worldTable}
    -- Rozmiary swiata (ma byc prostokatny)
    for y,row in ipairs(worldTable) do
        assert(#row == newWorld.size[1], 'World row size inconsistent (row #' .. newWorld.size[2] - y + 1 .. ')')
    end
    -- Elementy maja byc stanami
    for rx,row in ipairs(worldTable) do
        for ry,node in ipairs(row) do
            --assert(type(node) == 'node', 'World element at raw index [' .. rx .. '][' .. ry .. '] is not a node')
        end
    end
    newWorld.nodes = worldTable
    -- Domyslne parametry
    newWorld.params = {
        discountFactor = params.discountFactor or 1,
        actionDistribution = params.actionDistribution or {
            straight = 0.8,
            toLeft = 0.1,
            toRight = 0.1,
            opposite = 0
        },
        valIterTreshold = params.valIterTreshold or 0.0001,
        Qepsilon = params.Qepsilon or 0.01,
    }
    
    return newWorld
end

-- Akcje (pozycja) -> (pozycja)
world.actions = {
    left = function(world, pos)
        local newPos = {pos[1]-1, pos[2]}
        return world:ValidPos(newPos) and newPos or pos
    end,
    right = function(world, pos)
        local newPos = {pos[1]+1, pos[2]}
        return world:ValidPos(newPos) and newPos or pos
    end,
    up = function(world, pos)
        local newPos = {pos[1], pos[2]+1}
        return world:ValidPos(newPos) and newPos or pos
    end,
    down = function(world, pos)
        local newPos = {pos[1], pos[2]-1}
        return world:ValidPos(newPos) and newPos or pos
    end
}

-- Relacje akcji
world.actionLayout = {
    left = {
        straight = 'left',
        toLeft = 'down',
        toRight = 'up',
        opposite = 'right'
    },
    right = {
        straight = 'right',
        toLeft = 'up',
        toRight = 'down',
        opposite = 'left'
    },
    up = {
        straight = 'up',
        toLeft = 'left',
        toRight = 'right',
        opposite = 'down'
    },
    down = {
        straight = 'down',
        toLeft = 'right',
        toRight = 'left',
        opposite = 'up'
    }
}

-- TODO: USUN MNIE
local posLUT = {}
world.pos = function(self, node)
    if posLUT[node] then
        return posLUT[node]
    end
    for x = 1, self.size[1] do
        for y = 1, self.size[2] do
            if self{x, y} == node then
                posLUT[node] = {x, y}
                return {x, y}
            end
        end
    end
    error('Jesus')
end

-- Wykonanie akcji razem z niepewnoscia
-- (node, action) -> (node)
world.PerformAction = function(self, currNode, action)
    local rand = math.random()
    local sum = 0
    local resolution
    for res,prob in pairs(self.params.actionDistribution) do
        if resolution then break end
        if rand <= (prob+sum) then
            resolution = res
        else
            sum = sum + prob
        end
    end
    local pos = self:pos(currNode)
    return self(self.actions[self.actionLayout[action][resolution]](self, pos))
end

-- Uzytecznosc akcji z uzytecznosci stanow wkolo
world.actionUtility = function(self, pos, actionName)
    local sum = 0
    for resolution, action in pairs(self.actionLayout[actionName]) do
        sum = sum + (self.params.actionDistribution[resolution] * self(world.actions[action](self, pos)).utility)
    end
    return sum
end
-- Max powyzszego + odpowiadajaca akcja
world.maxActionUtility = function(self, pos)
    local max = {util = -1*math.huge, action = nil}
    for actionName in pairs(world.actionLayout) do
        local util = self:actionUtility(pos, actionName)
        if util > max.util then
            max.util = util
            max.action = actionName
        end
    end
    return max.util, max.action
end


-- Czy pozycja w ramach swiata
world.InBounds = function(self, pos)
    return pos[1] > 0 and pos[1] <= #self.nodes[1] and pos[2] > 0 and pos[2] <= #self.nodes
end
world.AssertInBounds = function(self, pos)
    assert(self:InBounds(pos), string.format('Position {%i, %i} not in bounds of world (size: {%i, %i})', pos[1], pos[2], unpack(self.size)))
end
-- Czy pozycja mozliwa do wejscia
world.ValidPos = function(self, pos)
    return self:InBounds(pos) and (not self(pos).forbidden)
end



-- Indeksowanie, {0,0} w lewym dolnym rogu
world.GetNode = function(self, pos)
    self:AssertInBounds(pos)
    return self.nodes[#self.nodes-pos[2]+1][pos[1]]
end

-- Pozycja startowa dla uczenia
world.SetStartingPos = function(self, pos)
    self:AssertInBounds(pos)
    if self.startPos then
        self(pos).starting = false
    end
    self.startPos = pos
    self(pos).starting = true
end
world.GetStartingPos = function(self)
    return self.startPos or error('Starting position not set')
end

-- Formatowanie
local function addedSign(val)
    return val >= 0 and ' ' or ''
end
local function hPad(val)
    local av = math.abs(val)
    if av < 10 then
        return '  '
    elseif av < 100 then
        return ' '
    end
    return ''
end
local function nodeString(node, format)
    format = format:gsub('%%S', node:Symbol())
    format = format:gsub('%%U', addedSign(node.utility) .. string.format('%.4f', node.utility))
    format = format:gsub('%%R', addedSign(node.reward) .. hPad(node.reward) .. string.format('%.3f', node.reward))
    return format
end
world.PrintState = function(self)
    io.write('\nSWIAT (' .. tostring(self) .. ')\n')
    io.write('-- POLA: --\n')
    for y=self.size[2],1,-1 do
        for x = 1,self.size[1] do
            io.write(nodeString(self({x, y}), '[%S:%R]'), '   ')
        end
        io.write('\n')
    end
    io.write('--  ---  --\n')
    io.write('PARAMETRY:\n')
    io.write('- dyskontowanie: ', self.params.discountFactor, '\n')
    local ad = self.params.actionDistribution
    io.write('- dystrybucja prawd. akcji: { F = ', ad.straight, ', L = ', ad.toLeft, ', R = ', ad.toRight, ', B = ', ad.opposite, '}\n')
    io.write('- dokladnosc obliczen: ', self.params.valIterTreshold, '\n')
    io.write('--  ---  --\n')
end
world.PrintUtilities = function(self)
    io.write('\nSWIAT (' .. tostring(self) .. ')\n')
    io.write('-- UZYTECZNOSCI: --\n')
        for y=self.size[2],1,-1 do
            for x = 1,self.size[1] do
                io.write(nodeString(self({x, y}), '%U'), '   ')
            end
        io.write('\n')
    end
end
local policySymbols = {
    up      = '  ^ ',
    left    = '  < ',
    right   = '  > ',
    down    = '  v ',
}
world.PrintPolicy = function(self)
    io.write('\nSWIAT (' .. tostring(self) .. ')\n')
    io.write('-- POLITYKA: --\n')
        for y=self.size[2],1,-1 do
            for x = 1,self.size[1] do
                local node = self{x, y}
                if node.forbidden then
                    io.write('  x ')
                elseif node.terminal then
                    io.write('  T ')
                else
                    local _, bestAction = self:maxActionUtility{x, y}
                    io.write(policySymbols[bestAction])
                end
            end
        io.write('\n')
    end
end



return world