console.log("In player Client")

net = require('net')
Utils = require "./utils"
@utils = new Utils
utilsL = @utils

N = @utils.N
HOST = @utils.HOST
MATCHMAKER_PORT = @utils.MATCHMAKER_PORT
PLAYER_PORT = @utils.PLAYER_PORT

lastReceivedNumbers = []
lastReceivedScore = 0

connectingPort =
    port: PLAYER_PORT

# EDIT HERE TO PLACE YOUR OWN MOVE
makeCandidate = () ->
    basicCandidate = createBasicCandidate()
    
createBasicCandidate = () ->
    candidate = []
    weightValue = 1/(N/2)
    weightValue = weightValue.toFixed(2)
    #console.log("Weight Value: #{weightValue}")
    weightValue = parseFloat(weightValue)
    negativeWeightValue = 0.0
    positiveWeightValue = 0.0
    for index in [1..N]
        if index % 2 is 0
            candidate.push(weightValue)
            positiveWeightValue = weightValue + positiveWeightValue
        else
            candidate.push(-weightValue)
            negativeWeightValue = weightValue + negativeWeightValue

    positiveWeightValue = positiveWeightValue.toFixed(2)
    negativeWeightValue = negativeWeightValue.toFixed(2)

    if positiveWeightValue < 1
        value = candidate[1]
        value += (1 - positiveWeightValue)
        candidate[1] = value.toFixed(2)

    else if positiveWeightValue > 1
        value = candidate[1]
        value -= (positiveWeightValue - 1)
        value.toFixed(2)
        candidate[1] = value.toFixed(2)

    if negativeWeightValue < 1
        value = candidate[0]
        value -= (1 - negativeWeightValue)
        value.toFixed(2)
        candidate[0] = value.toFixed(2)

    else if positiveWeightValue > 1
        value = candidate[0]
        value += (negativeWeightValue - 1)
        value.toFixed(2)
        candidate[0] = value.toFixed(2)

    candidate

client = net.connect(connectingPort, ->
    console.log("Player client connected on port #{connectingPort.port}")
    candidate = makeCandidate()
    candidateString = utilsL.convertNumArrayToFormattedString(candidate)
    client.write(candidateString))


client.on 'data', (data) ->
    data = data.toString()
    
    if data != "gameover"
        candidate = makeCandidate()
        candidateString = utilsL.convertNumArrayToFormattedString(candidate)
        console.log("Player Client sending data")
        client.write(candidateString)
    else
        console.log("GAMEOVER")
