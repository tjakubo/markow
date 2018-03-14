local gnuplot = {}

gnuplot.bin = 'G:\\gnuplot\\bin\\gnuplot.exe'

local scriptName = 'plot.gp'
local dataName = 'points.out'

gnuplot.defaultFlags = {
    --terminal = 'png',
    --output = '"output.png"',
    terminal = 'windows',
    autoscale = '',
    grid = '',
    key = 'right bottom'
}
    
gnuplot.setDefaultFlags = function(flags)
    for f,v in pairs(gnuplot.defaultFlags) do
        if flags[f] == nil then
            flags[f] = v
        end
    end
    return flags
end

gnuplot.plot = function(flags, yDataSet)
    flags = gnuplot.setDefaultFlags(flags)
    local script = {}
    for f,v in pairs(flags) do
        if v then
            script[#script+1] = 'set ' .. f .. ' ' .. v
        end
    end
    script[#script+1] = ''
    for k=1,#yDataSet do
        script[#script+1] = (k==1 and 'plot ' or ' ') .. '"' .. dataName .. '" using ' .. k .. ' title "' .. (yDataSet[k].label or tostring(k-1)) .. '" with lines, \\'
    end
    script[#script] = script[#script]:gsub(', \\', '')
    local scriptFile = io.open(scriptName, 'w')
    scriptFile:write(table.concat(script, '\n'))
    scriptFile:write('\n pause -1')
    scriptFile:close()
    
    local dataFile = io.open(dataName, 'w')
    for k=1,#yDataSet[1] do
        local line = {}
        for k2=1,#yDataSet do
            line[#line+1] = yDataSet[k2][k]
        end
        dataFile:write(table.concat(line, ' '), '\n')
    end
    dataFile:close()
    
    os.execute(string.format('%s -persist %s', gnuplot.bin,  scriptName))
end

return gnuplot