net = require('net')

Utils = require "./utils"
utilsL = new Utils
playerSocket = net.createServer()

class Player
    constructor: () ->
        @utils = new Utils
        @epsilon = @utils.epsilon
        @N = @utils.N
        @HOST = @utils.HOST
        @PLAYER_PORT = @utils.PLAYER_PORT
        @time_left_in_seconds = 120
        console.log(@time_left_in_seconds)

    checkIfSumToCorrectValues: (numbers) ->
        totalPositiveValue = 0
        totalNegativeValue = 0

        for number in numbers
            if number > 0
                totalPositiveValue += number
            else
                totalNegativeValue += number

        if Math.abs(totalPositiveValue - 1) < @epsilon and
                Math.abs(totalNegativeValue + 1) < @epsilon
            valid = true

        else
            console.log("Received an invalid Candidate from Player")
            console.log("Total positive value is #{totalPositiveValue}")
            console.log("Total negative value is #{totalNegativeValue}")
            valid = false
          valid

    addListener: (@listener) ->
        console.log("Player added Listener")

    checkIfInitialNumbersAreValid: (initialNumbers) ->
        valid = @briefCheckIfNumbersValid(initialNumbers)

    checkIfChangedFivePercentOfWeights: (numbers) ->
        maxAllowedToChange = @N/20
        totalChanged = 0

        for index in [0..numbers.length - 1]
            if numbers[index] isnt @lastValidNums[index]
                totalChanged += 1

        valid = totalChanged <= maxAllowedToChange

    checkIfChangedValuesAreMaxTwentyPercentDifferent: (numbers) ->
        for index in [0..numbers.length - 1]
            currentTestingNum = numbers[index]
            currentValidNum = @lastValidNums[index]
            if currentTestingNum isnt currentValidNum
                percentValue = currentTestingNum/currentValidNum
                if percentValue < 0.8 or percentValue > 1.2
                    return false

        true

    checkIfLatterValuesAreValid: (numbers) ->
        if not @briefCheckIfNumbersValid(numbers)
            return false
        else if not @checkIfChangedFivePercentOfWeights(numbers)
            return false
        else if not @checkIfChangedValuesAreMaxTwentyPercentDifferent(numbers)
            return false
        else
            return true

    briefCheckIfNumbersValid: (numbers) ->
        if numbers.length != @N
            console.log("Length Incorrect: length is #{numbers.length}")
            return false
        if not @checkIfSumToCorrectValues(numbers)
            console.log("Sum incorrect")
            return false

        for number in numbers
            if number < -1
                console.log("Number is less than -1, it is #{number}")
                return false
            else if number > 1
                console.log("Number is greater than 1, it is #{number}")
                return false
            else if utilsL.numberOfDecimals(number) > 2
                console.log("Number has too many decimals, it is #{number}")
                return false
        true

    toString: -> console.log("Player ToString")

    # If valid, we update last valid and send to listner
    # If it isnt valid, we send the last valid nums to listener
    # If none valid so far, we make current valid
    receivedMessage: (message) ->
        #console.log("Player Socket Received Message: #{message}")
        @currentNums = utilsL.convertStringToNumArray(message)

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

        time_message_received = new Date().getTime()
        total_turnaround_time = (time_message_received - @time_message_sent) / 1000
        total_turnaround_time = 0 if isNaN(total_turnaround_time)
        @time_left_in_seconds = Math.ceil(@time_left_in_seconds - total_turnaround_time)
        console.log("Time left for Player in seconds: " + @time_left_in_seconds)
        @listener.receivedCandidateFromP(@lastValidNums)

    sendMessage: (message) ->
        #console.log("player socket sending message")
        @client.write(message)
        @time_message_sent = new Date().getTime()

    startServer: () ->
        @server = playerSocket
        @server.on 'connection', (@client) =>
            @listener.connectedToP()
            @client.on 'data', (data) =>

                #console.log("Player Socket Recieved Message")
                @receivedMessage(data)

        @server.listen @PLAYER_PORT
        console.log("Player Port Started on port #{@PLAYER_PORT}")

    timed_out: () ->
      return @time_left_in_seconds < 0

module.exports = Player
