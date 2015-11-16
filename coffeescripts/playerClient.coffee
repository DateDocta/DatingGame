net = require('net')
Utils = require "./utils"
utils = new Utils

N = utils.N
HOST = utils.HOST
MATCHMAKER_PORT = utils.MATCHMAKER_PORT
PLAYER_PORT = utils.PLAYER_PORT

lastReceivedNumbers = []
lastReceivedScore = 0

server = net.createServer()

# EDIT HERE TO PLACE YOUR OWN MOVE
makeCandidate = () ->
    basicCandidate = createBasicCandidate()
    
createBasicCandidate = () ->
    candidate = []
    weigthValue = 1/(N/2)
    for index in [1..N]
        if index % 2 is 0
            candidate.push(weightValue)
        else
            candidate.push(-weightValue)

    candidate

server.on 'connection', (client) ->

    candidate = makeCandidate()
    candidateString = utils.convertNumArrayToFormattedString(candidate)
    client.write(candidateString)

    client.on 'data', (data) ->
        if data is not "gameover"
            candidate = makeCandidate()
            candidateString = utils.convertNumArrayToFormattedString(candidate)
            client.write(candidateString)

server.listen PLAYER_PORT
