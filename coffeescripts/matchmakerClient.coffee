console.log("In matchMaker Client")

net = require('net')
Utils = require "./utils"
utils = new Utils

N = utils.getN()
HOST = utils.getHOST()
MATCHMAKER_PORT = utils.getMATCHMAKER_PORT()
PLAYER_PORT = utils.getPLAYER_PORT()

console.log("Matchmaker Port #{MATCHMAKER_PORT}")

connectingPort =
    port: MATCHMAKER_PORT

lastReceivedNumbers = []
lastReceivedScore = 0

parseData = (data) ->
    if data.split("\n").length > 10
        parseMultipleCandidates(data)
    else
        parseSingleCandidate(data)

parseSingleCandidate = (data) ->
    lastReceivedCandidate = []

    splitData = data.split(/\D/)
    for index in [0..N-1]
        lastReceivedNumber.push(splitData[index])

    #lastReceivedScore = splitData[splitData.length - 1]
    lastReceivedScore = splitData[N+2]

parseMultipleCandidates = (data) ->
   totalCandidates = []
   totalCandidatesScores = []
   currentCandidate = []
   currentCandidateScore = 0


   splitData = data.split(/\D/)

   valuesPerCandidate = N + 4
   totalIterations = splitData.length / valuesPerDandidate

   for i in [1..totalIterations]
       for j in [0..N-1]
           currentCandidate.push(splitData[j])
           
        currentCandidateScore = splitData[N+2]
        totalCandidates.push(currentCandidate)
        totalCandidatesScores.push(currentCandidateScore)
        splitData.splice(0, valuesPerCandidate)

    console.log("Total Candidates: ")
    console.log(totalCandidates)
    console.log("Total Scores: ")
    console.log(totalCandidatesScores)

# EDIT HERE TO PLACE YOUR OWN MOVE
makeCandidate = () ->
    randomCandidate = createRandomCandidate()
    
createRandomCandidate = () ->
    candidate = []
    for weight in [1..N]
        candidate.push(Math.random().toFixed(4))

    candidate

client = net.connect(connectingPort, ->
    console.log("MM Client Connected"))

client.on 'data', (data) ->
    console.log("MM Client Received Data")
    if data is not "gameover"
        console.log("MM Client sending data")
        parseData(data)
        candidate = makeCandidate()
        candidateString = utils.convertNumArrayToFormattedString(candidate)
        client.write(candidateString)
