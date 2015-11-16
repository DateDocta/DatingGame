console.log("In player Client")
net = require('net')
Utils = require "./utils"
utils = new Utils

N = utils.getN()
HOST = utils.getHOST()
MATCHMAKER_PORT = utils.getMATCHMAKER_PORT()
PLAYER_PORT = utils.getPLAYER_PORT()

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
    console.log("Player Client Created")
    candidate = makeCandidate()
    candidateString = utils.convertNumArrayToFormattedString(candidate)
    client.write(candidateString))

client.on 'data', (data) ->
    console.log("Player Client Received Data")

    if data is not "gameover"
        console.log("Player Client sending data")
        candidate = makeCandidate()
        candidateString = utils.convertNumArrayToFormattedString(candidate)
        client.write(candidateString)
