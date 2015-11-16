net = require('net')
Utils = require "./utils"
playerSocket = net.createServer()

class Player
	constructor: (@listener) ->
        @utils = new Utils
        @N = @utils.getN()
        @HOST = @utils.getHOST()
        @PLAYER_PORT = @utils.getPLAYER_PORT()

        ###
        @server = playerSocket
        @server.on 'connection', (@client) ->
            console.log("Connection Made with player")
            @client.on 'data', (data) ->
                console.log("received player data")
                @receivedMessage(data)

        @server.listen @PLAYER_PORT
        console.log("Player Port Started")
        ###
        @startServer()

    checkIfSumToCorrectValues: (numbers) ->
        totalPositiveValue = 0
        totalNegativeValue = 0

        for number in numbers
            if number > 0
                totalPositiveNumber += number
            else
                totalNegativeNumber += number

        valid = totalPositiveValue is 1 and totalNegativeValue is -1

    checkIfInitialNumbersAreValid: (initialNumbers) ->
        valid = briefCheckIfNumbersValid(initialNumbers)

    checkIfChangedFivePercentOfWeights: (numbers) ->
        maxAllowedToChange = @N/20
        totalChanged = 0

        for index in [0..numbers.length - 1]
            if numbers[index] is not @lastValidNums[index]
                totalChanged += 1

        valid = totalChanged <= maxAllowedToChange

    checkIfChangedValuesAreMaxTwentyPercentDifferent: (numbers) ->
        for index in [0..numbers.length - 1]
            currentTestingNum = numbers[index]
            currentValidNum = @lastValidNums[index]
            if currentTestingNum is not currentValidNum
                percentValue = currentTestingNum/currentValidNum
                if percentValue < 0.8 or percentValue > 1.2
                    return false

        true

    checkIfLatterValuesAreValid: (numbers) ->
        if not briefCheckIfNumbersValid(numbers)
            return false
        else if not checkIfChangedFivePercentOfWeights(numbers)
            return false
        else if not checkIfChangedValuesAreMaxTwentyPercentDifferent(numbers)
            return false
        else
            return true

    briefCheckIfNumbersValid: (numbers) ->
        if numbers.length != @N
            return false
        if not checkIfSumToCorrectValues(numbers)
            return false

        for number in numbers
            if number < -1
                return false
            else if number > 1
                return false
            else if @utils.numberOfDecimals(number) > 2
                return false
        true

    # If valid, we update last valid and send to listner
    # If it is not valid, we send the last valid nums to listener
    # If none valid so far, we make current valid
    receivedMessage: (message) ->
        console.log("Player Socket Recieved Message")
        @currentNums = @utils.convertStringToNumArray(message)

        if typeof @lastValidNums is 'undefined'
            valid = @briefCheckIfNumbersValid(@currentNums)
            if valid
                @lastValidNums = @currentNums
            else
                console.log("FIRST RECEIVED NUMBERS FROM PLAYER NOT VALID")
                return
        else
            valid = @checkIfLatterValuesAreValid(@currentNums)
            if valid
                @lastValidNums = @currentNums

        @listner.receivedCandidateFromP(@lastValidNums)

    sendMessage: (message) ->
        console.log("player socket sending message")
        @client.write(message)

    startServer: () ->
        @server = playerSocket
        @server.on 'connection', (@client) ->
            console.log("Connection Made with player")
            @client.on 'data', (data) ->
                console.log("received player data")
                @receivedMessage(data)

        @server.listen @PLAYER_PORT
        console.log("Player Port Started")

module.exports = Player
