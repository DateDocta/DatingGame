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
    for index in [1..N]
        if index % 2 is 0
            candidate.push(weightValue)
        else
            candidate.push(-weightValue)

    candidate

client = net.connect(connectingPort, ->
    console.log("Player client connected on port #{connectingPort.port}")
    candidate = makeCandidate()
    candidateString = utilsL.convertNumArrayToFormattedString(candidate)
    client.write(candidateString))


client.on 'data', (data) ->
    #console.log("Player Client Received Data: #{data}")
    data = data.toString()
    
    if data != "gameover"
        candidate = makeCandidate()
        candidateString = utilsL.convertNumArrayToFormattedString(candidate)
        console.log("Player Client sending data")
        client.write(candidateString)
    else
        console.log("GAMEOVER")
