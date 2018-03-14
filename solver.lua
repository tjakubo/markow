local solver = {}

-- Pojedyncza iteracja wartosci
solver.valIterPass = function(world, n)
    local maxDiff = 0
    for x = 1, world.size[1] do
        for y = 1, world.size[2] do
            local node = world{x, y}
            if not node.terminal and not node.forbidden then
                local newUtility = node.reward + world.params.discountFactor * world:maxActionUtility{x, y}
                maxDiff = math.max(math.abs(node.utility - newUtility), maxDiff)
                node.utility = newUtility
            end
        end
    end
    return maxDiff
end

-- TODO: USUN MNIE
local function saveUtilities(world, data)
    local k = 1
    for x = 1, world.size[1] do
        for y = 1, world.size[2] do
            data[k][#data[k]+1] = world{x, y}.utility
            k = k+1
        end
    end
end

-- Iteracja wartosci dopoki roznica powyzej valIterTreshold
solver.ValIter = function(world)
    local diff, n = nil, 0
    local data = {}
    for x = 1, world.size[1] do
        for y = 1, world.size[2] do
            data[#data+1] = {label = x .. ',' .. y}
        end
    end
    
    repeat
        saveUtilities(world, data)
        diff = solver.valIterPass(world, n)
        n = n+1
    until diff < world.params.valIterTreshold
    return data
end

-- Qlearning, zadana ilosc iteracji
solver.Qlearning = function(world, iters)
    local Q = {}
    local Nsa = {}
    local prev = {
        state = nil,
        action = 'none',
        reward = nil
    }
    
    for x = 1, world.size[1] do
        for y = 1, world.size[2] do
            local node = world{x, y}
            Q[node]   = {left = 0, right = 0, up = 0, down = 0, none = 0}
            Nsa[node] = {left = 0, right = 0, up = 0, down = 0, none = 0}
        end
    end
    
    local function alpha(Nsa)
        if not Nsa then return 0 end
        return 1/Nsa
    end
    
    local actions = {'left', 'right', 'up', 'down'}
    local function bestQaction(state, Q)
        local max, best = -1*math.huge, nil
        for _,action in ipairs(actions) do
            if Q[state][action] > max then
                max = Q[state][action]
                best = action
            end
        end
        return max, best
    end
    
    local startState = world(world:GetStartingPos())
    local currState = startState
    
    local currIter = 1
    while currIter < iters do
        --print(currIter)
        if prev.state then
            Nsa[prev.state][prev.action] = Nsa[prev.state][prev.action] + 1
            local lf = alpha(Nsa[prev.state][prev.action])
            local inc = prev.reward + world.params.discountFactor*bestQaction(currState, Q) - Q[prev.state][prev.action]
            Q[prev.state][prev.action] = Q[prev.state][prev.action] + lf*inc
        end
        prev.state = currState
        prev.reward = currState.reward
        
        if currState.terminal then
            Q[prev.state][prev.action] = currState.reward
            currState = startState
            currIter = currIter+1
            prev = {
                state = nil,
                action = 'none',
                reward = nil
            }
        else
            local newAction
            if math.random() < world.params.Qepsilon then
                newAction = actions[math.random(1, #actions)]
            else
                _, newAction = bestQaction(currState, Q)
            end
            prev.action = newAction
            
            currState = world:PerformAction(currState, newAction)
        end
    end
    
    for node, data in pairs(Q) do
        --node.utility = bestQaction(node, Q)
        node.utility = Q[node].up
    end
    return Q
end

return solver