Player = require "./player"
MatchMaker = require "./matchmaker"
Utils = require "./utils"

class Game
    constructor: ->
        @utils = new Utils
        @matchMaker = new MatchMaker this
        @player = new Player this
        @N = @utils.N
        @waitingForMMCandidate = false
        @waitingForPCandidate = true
        @turn = 0

        @maxScore = -100

        @setup()

    setup: ->
        @matchMaker.addListener(this)
        @player.addListener(this)
        @matchMaker.startServer()
        @player.startServer()

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

    updateMaxValues: (score) ->
        if score > @maxScore
            @maxScore = score
            @maxScoreTurn = @turn
            @maxMMVector = @currentMMCandidate
            @maxPVector = @currentPCandidate

    analyzeGame: ->
        # Check if we have received messages from P and M
        if @waitingForMMCandidate or @waitingForPCandidate
            return

        # Initial Turn
        if @turn is 0
            
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
            @turn += 1
            score = @scoreVector(@currentMMCandidate, @currentPCandidate)
            @updateMaxValues(score)

            if score is 1 or @turn is 20
                @endGame()

            else
                pMessage = "continue"
                mmMessage = @scoredCandidateString(@currentMMCandidate, @currentPCandidate)
                @waitingForPCandidate = true
                @waitingForMMCandidate = true
                @turn += 1
                @matchMaker.sendMessage(mmMessage)
                @player.sendMessage(pMessage)


    endGame: ->
        # Max Scores
        endMessage = ""
        endMessage += "Ultimate Score is (#{@maxScore}, #{@turn})"
        endMessage += "Breakdown of Score\n"
        endMessage += "-----------------------------------\n\n"
        endMessage += "Turn of Max Score: #{@maxScoreTurn}\n"
        endMessage += "Max Score: #{@maxScore}\n"
        endMessage += "Matchmaker Candidate with Max Score: #{@maxMMVector}\n"
        endMessage += "Player Candidate at turn of Max Score: #{@maxMMVector}\n"

        endMessage += "\n\n"

        # Last Turn Scores
        score = @scoreVector(@currentMMCandidate, @currentPCandidate)
        endMessage += "Turn #{@turn}\n"
        endMessage += "Last Turn Score: #{score}\n"
        endMessage += "Last Matchmaker Candidate: #{@currentMMCandidate}\n"
        endMessage += "Last Player Candidate: #{@currentPCandidate}\n"

        console.log(endMessage)
        @matchMaker.sendMessage("gameover")
        @player.sendMessage("gameover")

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
