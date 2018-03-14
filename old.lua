local initUtility = 0
function node(value, terminal)
    terminal = terminal and true or false
    local forbidden = not value
    value = value or 0
    local node = {value = value, forbidden = forbidden, terminal = terminal, utility = terminal and value or initUtility}
    return setmetatable(node, {
        __tostring = function(self)
            return string.format('Node: %d @ %.3f [%s%s]', self.value, self.utility, self.terminal and 'T' or '', self.forbidden and 'F' or ''):gsub('%[%]', '')
        end
    })
end

local ev = -1

--[[world = {
    {node(ev), node(ev),    node(ev), node(1, true)  },
    {node(ev), node(false), node(ev), node(-1, true) },
    {node(ev), node(ev),    node(ev), node(ev)       },
}]]--

world = {
    {node(ev), node(ev), node(ev),    node(ev)},
    {node(ev), node(ev), node(ev),    node(ev)},
    {node(ev), node(ev), node(-20),   node(ev)},
    {node(ev), node(ev), node(false), node(100, true)},
}


function inBounds(pos)
    return pos[1] > 0 and pos[2] > 0 and pos[1] <= #world[1] and pos[2] <= #world
end

setmetatable(world,
    {
        __call = function(self, pos)
            assert(inBounds(pos), 'Queried point {' .. table.concat(pos, ', ') .. '} out of bounds')
            return self[#self-pos[2]+1][pos[1]]
        end
})
world.limits = {#world[1], #world}

function valid(pos)
    return inBounds(pos) and not world(pos).forbidden
end

function left(pos)
    local newPos = {pos[1]-1, pos[2]}
    return valid(newPos) and newPos or pos
end
function right(pos)
    local newPos = {pos[1]+1, pos[2]}
    return valid(newPos) and newPos or pos
end
function up(pos)
    local newPos = {pos[1], pos[2]+1}
    return valid(newPos) and newPos or pos
end
function down(pos)
    local newPos = {pos[1], pos[2]-1}
    return valid(newPos) and newPos or pos
end

math.randomseed(os.time())
local actionDefs = {
    up = {
        {prob = 0.1, result = left},
        {prob = 0.1, result = right},
        {prob = 0.8, result = up},
    },
    down = {
        {prob = 0.1, result = left},
        {prob = 0.1, result = right},
        {prob = 0.8, result = down},
    },
    left = {
        {prob = 0.1, result = up},
        {prob = 0.1, result = down},
        {prob = 0.8, result = left},
    },
    right = {
        {prob = 0.1, result = up},
        {prob = 0.1, result = down},
        {prob = 0.8, result = right},
    }
}
actions = {}
for action, outcomeTable in pairs(actionDefs) do
    actions[action] = function(pos)
        local rand = math.random()
        local sum = 0
        for k, outcome in ipairs(outcomeTable) do
            if rand <= (outcome.prob + sum) then
                return outcome.result(pos)
            else
                sum = sum + outcome.prob
            end
        end
    end
end

local disc = 0.99
local function actionUtility(pos, actionName)
    local sum = 0
    for k, actionData in ipairs(actionDefs[actionName]) do
        sum = sum + (actionData.prob * world(actionData.result(pos)).utility)
    end
    return sum
end
local function maxActionUtility(pos)
    local max = -1*math.huge
    for actionName in pairs(actions) do
        local util = actionUtility(pos, actionName)
        if util > max then
            max = util
        end
    end
    return max
end
function valIterPass()
    for x = 1, world.limits[1] do
        for y = 1, world.limits[2] do
            local node = world{x, y}
            if not node.terminal and not node.forbidden then
                node.utility = node.value + disc*maxActionUtility{x, y}
            end
        end
    end
end

function printWorldUtility()
    for y = world.limits[2], 1, -1 do
        io.write('\n')
        for x = 1, world.limits[1] do
            io.write(string.format('%.3f  ', world{x, y}.utility))
        end
    end
    io.write('\n')
end
local iter = 1
for k=1,iter do
    valIterPass()
end
printWorldUtility()

--[[
local tPos = {3, 1}
local res = {}
for k=1,100000 do
    local result = table.concat(actions.up(tPos), ', ')
    res[result] = res[result] or 0
    res[result] = res[result] + 1
end
for k,v in pairs(res) do
    print(k, v)
end
]]--
--print( world{1,1} )