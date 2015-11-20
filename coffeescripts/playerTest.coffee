
Player = require "./player"
MatchMaker = require "./matchmaker"
Utils = require "./utils"

utilsL = new Utils
player = new Player this

testString = "0.25 0.04 0.01 0.14 0.56 -0.2 -0.06 -0.14 -0.29 -0.31"
testNumbers = utilsL.convertStringToNumArray(testString)


console.log("Test numbers length is #{testNumbers.length}")
console.log("Numbers are: ")
for number in testNumbers
    console.log(number)

valid = player.checkIfInitialNumbersAreValid(testNumbers)
console.log("Valid = #{valid}")
