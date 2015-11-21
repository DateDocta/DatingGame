net = require('net')
Utils = require "./utils"
utilsL = new Utils
matchmakerSocket = net.createServer()

class MatchMaker
	constructor: () ->
        @utils = new Utils
        @N = @utils.N
        @HOST = @utils.HOST
        @MATCHMAKER_PORT = @utils.MATCHMAKER_PORT
        @time_left_in_seconds = 120

    addListener: (@listener) ->
        console.log("MM added Listener")

    checkIfNumbersValid: (numbers) ->
        if numbers.length != @N
            return false
        for number in numbers
            if number < 0
                return false
            else if number > 1
                return false
            else if utilsL.numberOfDecimals(number) > 4
                return false
        true

    # Makes Matchmaker input valid
    # We adjust size and make it 
    # inclusive 0 to 1
    makeNumsValid: (numbers) ->
        if numbers.length > @N
            amountToRemove = numbers.length - @N
            numbers = numbers.slice(@N, amountToRemove)
        else if numbers.length < @N
            additionalNumsNeedded = @N - numbers.length
            for [0..additionalNumsNeeded]
                numbers.push(0)

        for num, index in numbers
            if num < 0
                numbers[index] = 0
            else if num > 1
                numbers[index] = 1

        numbers

    # If valid, we update last valid and send to listner
    # If it isnt valid, we send the last valid nums to listener
    # If none valid so far, we make current valid
    receivedMessage: (message) ->
        #console.log("Matchmaker Socket Recieved Message")
        @currentNums = utilsL.convertStringToNumArray(message)
        valid = @checkIfNumbersValid(@currentNums)
        if valid
            @lastValidNums = @currentNums
        else
            if typeof @lastValidNums is 'undefined'
                @currentNums = utilsL.convertStringToNumArray(message, 4)
                @lastValidNums = @makeNumsValid(@currentNums)

        time_message_received = new Date().getTime()
        total_turnaround_time = (time_message_received - @time_message_sent) / 1000
        @time_left_in_seconds = Math.ceil(@time_left_in_seconds - total_turnaround_time)
        console.log("Time left for MatchMaker in seconds: " + @time_left_in_seconds)
        @listener.receivedCandidateFromMM(@lastValidNums)

    sendMessage: (message) ->
        #console.log("Matchmaker socket sending message")
        @client.write(message)
        @time_message_sent = new Date().getTime()

    startServer: () ->
        @server = matchmakerSocket
        @server.on 'connection', (@client) =>
            @listener.connectedToMM()
            @client.on 'data', (data) =>
                #console.log("received mm data")
                @receivedMessage(data)
        @server.listen @MATCHMAKER_PORT
        console.log("Matchmaker Port started on port #{@MATCHMAKER_PORT}")

    timed_out: () ->
      return @time_left_in_seconds < 0


module.exports = MatchMaker
