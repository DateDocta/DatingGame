Player = require "./player"
MatchMaker = require "./matchmaker"
Utils = require "./utils"

class Game
    constructor: ->
        @utils = new Utils
        @matchMaker = new MatchMaker this
        @player = new Player this
        @N = @utils.N
        @MisConnected = false
        @PisConnected = false
        @waitingForMMCandidate = false
        @waitingForPCandidate = true
        @turn = 0

        @maxScore = -100

        @setup()

    delay: (ms, func) -> setTimeout func, ms

    setup: ->
        @matchMaker.addListener(this)
        @player.addListener(this)

        @delay 1000, =>
            @matchMaker.startServer()
            @player.startServer()

    checkIfBothPlayersConnected: () ->
        value = @PisConnected and @MisConnected

    receivedCandidateFromMM: (mmNumbers) ->
        console.log("Received MM candidate")
        if @waitingForMMCandidate
            @waitingForMMCandidate = false
            @currentMMCandidate = mmNumbers
            @analyzeGame()

    receivedCandidateFromP: (pNumbers) ->
        console.log("Received P candidate")
        if @waitingForPCandidate
            @waitingForPCandidate = false
            @currentPCandidate = pNumbers
            @analyzeGame()

    connectedToMM: () ->
        console.log("Game knows MM is connected")
        @MisConnected = true

        # Analyze Game call ensures we fuction correctly
        # if P connects first
        @analyzeGame()

    connectedToP: () ->
        console.log("Game knows P is connected")
        @PisConnected = true

    updateMaxValues: (score) ->
        if score > @maxScore
            @maxScore = score
            @maxScoreTurn = @turn
            @maxMMVector = @currentMMCandidate
            @maxPVector = @currentPCandidate

    analyzeGame: ->

        # Make sure we are all connected
        if not @checkIfBothPlayersConnected()
            return

        # Check if we have received messages from P and M
        if @waitingForMMCandidate or @waitingForPCandidate
            return


        # Initial Turn
        if @turn is 0
            
            # On turn one, we only need data from Player
            # This causes and issue if the player connects first, sends data
            # and we try to send data back to P and MM when MM isn't connected yet
            # This loop ensures we don't continue until both P and MM are connected
            loop
                bothPlayersConnected = @checkIfBothPlayersConnected()
                break if bothPlayersConnected

            #Create 20 rand cand, score, send to M
            mmMessage = ""

            for index in [1..20]
                randomCandidate = @createRandomCandidateForMM()
                mmMessage += @scoredCandidateString(randomCandidate, @currentPCandidate)
            
            @waitingForPCandidate = true
            @waitingForMMCandidate = true
            @turn += 1
            @matchMaker.sendMessage(mmMessage)
            @player.sendMessage("continue")

        # Remaining Turns
        else
            #Calc current Score, send messages, update turn
            score = @scoreVector(@currentMMCandidate, @currentPCandidate)
            @updateMaxValues(score)

            if score > 0.99999999 or @turn is 20
                @endGame()

            else
                @turn += 1
                pMessage = "continue"
                mmMessage = @scoredCandidateString(@currentMMCandidate, @currentPCandidate)
                @waitingForPCandidate = true
                @waitingForMMCandidate = true
                @matchMaker.sendMessage(mmMessage)
                @player.sendMessage(pMessage)


    endGame: ->
        # Max Scores
        endMessage = ""
        endMessage += "Ultimate Score is (#{@maxScore}, #{@turn})\n\n"
        endMessage += "Breakdown of Score\n"
        endMessage += "-----------------------------------\n\n"
        endMessage += "Turn of Max Score: #{@maxScoreTurn}\n\n"
        endMessage += "Max Score: #{@maxScore}\n\n"
        endMessage += "Matchmaker Candidate with Max Score: #{@maxMMVector}\n\n"
        endMessage += "Player Candidate at turn of Max Score: #{@maxPVector}\n"

        endMessage += "\n\n"

        # Last Turn Scores
        score = @scoreVector(@currentMMCandidate, @currentPCandidate)
        endMessage += "Turn #{@turn}\n"
        endMessage += "Last Turn Score: #{score}\n\n"
        endMessage += "Last Matchmaker Candidate: #{@currentMMCandidate}\n\n"
        endMessage += "Last Player Candidate: #{@currentPCandidate}\n"

        console.log(endMessage)
        @matchMaker.sendMessage("gameover")
        @player.sendMessage("gameover")

    # Dot Product
    scoreVector: (vectorA, vectorB) ->
        if vectorA.length is not vectorB.length
            throw "can't dot product different length arrays"
        score = 0
        for value, index in vectorA
            score += value * vectorB[index]
        score

    # Creates string "x1 x2 x3 x4 | score \n"
    scoredCandidateString: (matchmakerCandidate, playerCandidate = @currentPCandidate) ->
        returnString = ""
        score = @scoreVector(matchmakerCandidate, playerCandidate)
        
        for number in matchmakerCandidate
            returnString += number + " "

        returnString += "| " + score + " \n"

    createRandomCandidateForMM: ->
        numberArray = []
        for index in [1..@N]
            numberArray.push(Math.random().toFixed(4))
        numberArray

module.exports = Game
