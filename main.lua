--require 'util'
World  = require 'world'
Node   = require 'node'
Parser = require 'parser'
Solver = require 'solver'
gp = require 'gnuplot'

gp.bin = 'G:\\gnuplot\\bin\\gnuplot.exe'


local world = Parser.Read('worlds/1.lua', Node, World)
world:PrintState()

local iterData = Solver.ValIter(world)
world:PrintUtilities()
world:PrintPolicy()
io.write('\n', 'ITERACJA WARTOSCI - ' .. #iterData[1] .. ' iteracji', '\n')

local Q = Solver.Qlearning(world, 10000000)
world:PrintUtilities()
world:PrintPolicy()

io.flush()
gp.plot({}, iterData)