console.log("In matchMaker Client")

net = require('net')
Utils = require "./utils"
@utils = new Utils
utilsL = new Utils

N = @utils.N
HOST = @utils.HOST
MATCHMAKER_PORT = @utils.MATCHMAKER_PORT
PLAYER_PORT = @utils.PLAYER_PORT

console.log("Write originanl Way" + MATCHMAKER_PORT)
console.log("Matchmaker Port #{MATCHMAKER_PORT}")

connectingPort =
    port: MATCHMAKER_PORT

lastReceivedNumbers = []
lastReceivedScore = 0

parseData = (data) ->
    data = data.toString()
    if data.split("\n").length > 10
        parseMultipleCandidates(data)
    else
        parseSingleCandidate(data)

parseSingleCandidate = (data) ->
    data = data.toString()
    lastReceivedNumbers = []

    splitData = data.split(/\D/)
    for index in [0..N-1]
        lastReceivedNumbers.push(splitData[index])

    #lastReceivedScore = splitData[splitData.length - 1]
    lastReceivedScore = splitData[N+2]

parseMultipleCandidates = (data) ->

    totalCandidates = []
    totalCandidatesScores = []
    currentCandidate = []
    currentCandidateScore = 0

    data = data.toString()
    splitData = data.split(/\D/)

    valuesPerCandidate = N + 4
    totalIterations = splitData.length / valuesPerCandidate

    for i in [1..totalIterations]
        for j in [0..N-1]
            currentCandidate.push(splitData[j])
           
        currentCandidateScore = splitData[N+2]
        totalCandidates.push(currentCandidate)
        totalCandidatesScores.push(currentCandidateScore)
        splitData.splice(0, valuesPerCandidate)

# EDIT HERE TO PLACE YOUR OWN MOVE
makeCandidate = () ->
    randomCandidate = createRandomCandidate()
    
createRandomCandidate = () ->
    candidate = []
    for weight in [1..N]
        candidate.push(Math.random().toFixed(4))

    candidate

client = net.connect(connectingPort, ->
    console.log("MM Client Connected on port #{connectingPort.port}"))

client.on 'data', (data) ->
    data = data.toString()

    if data != "gameover"
        parseData(data)
        candidate = makeCandidate()
        candidateString = utilsL.convertNumArrayToFormattedString(candidate)
        console.log("MM Client sending data")
        client.write(candidateString)
    else
        console.log("GAMEOVER")
