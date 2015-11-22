class Utils
    N: 20
    HOST: '127.0.0.1'
    MATCHMAKER_PORT: 9696
    PLAYER_PORT: 6969
    EPSILON: 0.000001

    constructor: () ->

    toString: () ->
        console.log("Utils tostring called")

    numberOfDecimals: (number) ->
        number = number.toString()
        (number.split('.')[1] || []).length

    convertStringToNumArray: (numberString, decimalPoints = 0) ->
        numberString = numberString.toString()
        numberArray = []
        if numberString
            stringArray = numberString.trim().split(" ")
            size = stringArray.length
            if decimalPoints is 0
                for index in [0..size-1]
                    numberArray.push(parseFloat(stringArray[index]))
            else
                for index in [0..size-1]
                    numberArray.push(parseFloat(stringArray[index]).toFixed(decimalPoints))

            return numberArray
        else
            console.log("We are splitting an undefined")

    convertNumArrayToFormattedString: (numArray) ->
        returnString = ""
        for num in numArray
            returnString += num + " "

        returnString

module.exports = Utils
