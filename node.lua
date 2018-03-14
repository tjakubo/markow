local node = {}
node.defaultReward = 0  -- domyslna nagroda (zwykly stan)
node.defaultUtility = 0 -- poczatkowa uzytecznosc stanu

local nodeMeta = {
    __index = node
}

node.New = function(nodeData)
    local newNode = setmetatable({__type = 'node'}, nodeMeta)
    newNode.reward = nodeData.reward or node.defaultReward
    newNode.terminal = nodeData.terminal
    newNode.utility = (newNode.terminal and newNode.reward) or nodeData.utility or node.defaultUtility
    newNode.forbidden = nodeData.forbidden
    if newNode.forbidden then newNode.reward = 0 end
    return newNode
end

-- Zwykly stan
node.NewRegular = function()
    return node.New({})
end
node.R = node.NewRegular

-- Specjalny stan (B)
node.NewSpecial = function(reward)
    return node.New({reward = reward})
end
node.B = node.NewSpecial

-- Zakazany stan (F)
node.NewForbidden = function()
    return node.New({forbidden = true})
end
node.F = node.NewForbidden

-- Terminalny stan (T)
node.NewTerminal = function(reward)
    return node.New({reward = reward, terminal = true})
end
node.T = node.NewTerminal

-- Znaczek stanu
node.Symbol = function(self)
    if self.starting then
        return 'S'
    elseif self.terminal then
        return 'T'
    elseif self.forbidden then
        return 'F'
    elseif self.reward ~= node.defaultReward then
        return 'B'
    end
    return 'R'
end

node.ResetUtility = function(self)
    if not self.terminal then
        self.utility = note.defaultUtility
    end
    return not self.terminal
end

return node