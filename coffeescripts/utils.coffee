class Utils
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
                numberArray[index] =
                    parseFloat(value) for value, index in stringArray
            else
                numberArray[index] =
                    parseFloat(value)
                        .toFixed(decimalPoints) for value, index in stringArray

            return numberArray
        else
            console.log("We are splitting an undefined")

module.exports = Utils
