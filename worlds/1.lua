return {
    world = {
        { 'R',  'R',  'R',  'T:1'  },
        { 'R',  'F',  'R',  'T:-1' },
        { 'S',  'R',  'R',  'R',   },
    },
    defaultReward = -0.04,
    discountFactor = 1,
    
    actionDistribution = {
        straight = 0.8,
        toLeft = 0.1,
        toRight = 0.1,
        opposite = 0
    },
    
    valIterTreshold = 0.00001,
    Qepsilon = 0.05,
    
}