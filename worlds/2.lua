return {
    world = {
        { 'R',  'R',  'R',      'R'     },
        { 'R',  'R',  'R',      'R'     },
        { 'R',  'R',  'B:-20',  'R'     },
        { 'S',  'R',  'F',      'T:100' }
    },
    defaultReward = -1,
    discountFactor = 0.99,
    
    actionDistribution = {
        straight = 0.8,
        toLeft = 0.1,
        toRight = 0.1,
        opposite = 0
    },
    
    valIterTreshold = 0.00001,
    Qepsilon = 0.2,
    
}