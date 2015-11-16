class Utils

    constructor: () ->
        @N = 20
        @HOST = '127.0.0.1'
        @MATCHMAKER_PORT = 6969
        @PLAYER_PORT = 9696

    numberOfDecimals: (number) ->
        number = number.toString()
        (number.split('.')[1] || []).length

    convertStringToNumArray: (numberString, decimalPoints = 0) ->
        numberArray = []
        if numberString
            stringArray = numberString.split(" ")
            if decimalPoints is 0
                for index in [0..@N-1]
                    numberArray.push(parseFloat(stringArray[index]))
            else
                for index in [0..@N-1]
                    numberArray.push(parseFloat(stringArray[index]).toFixed(decimalPoints))

            return numberArray
        else
            console.log("We are splitting an undefined")

    convertNumArrayToFormattedString: (numArray) ->
        returnString = ""
        for num in numArray
            returnString += num + " "

        returnString

    toString: () ->
        console.log("Accessed in Utils")

    getN: () ->
        @N
    getHOST: () ->
        @HOST
    getMATCHMAKER_PORT: () ->
        @MATCHMAKER_PORT
    getPLAYER_PORT: () ->
        @PLAYER_PORT

module.exports = Utils
