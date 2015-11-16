// Generated by CoffeeScript 1.10.0
(function() {
  var Player, Utils, net, playerSocket;

  net = require('net');

  Utils = require("./utils");

  playerSocket = net.createServer();

  Player = (function() {
    function Player(listener) {
      this.listener = listener;
      this.utils = new Utils;
      this.N = this.utils.getN();
      this.HOST = this.utils.getHOST();
      this.PLAYER_PORT = this.utils.getPLAYER_PORT();
      this.server = playerSocket;
      this.server.on('connection', function(client) {
        this.client = client;
        console.log("Connection Made with player");
        return this.client.on('data', function(data) {
          console.log("received player data");
          return this.receivedMessage(data);
        });
      });
      this.server.listen(this.PLAYER_PORT);
      console.log("Player Port Started");
    }

    Player.prototype.checkIfSumToCorrectValues = function(numbers) {
      var i, len, number, totalNegativeValue, totalPositiveValue, valid;
      totalPositiveValue = 0;
      totalNegativeValue = 0;
      for (i = 0, len = numbers.length; i < len; i++) {
        number = numbers[i];
        if (number > 0) {
          totalPositiveNumber += number;
        } else {
          totalNegativeNumber += number;
        }
      }
      return valid = totalPositiveValue === 1 && totalNegativeValue === -1;
    };

    Player.prototype.checkIfInitialNumbersAreValid = function(initialNumbers) {
      var valid;
      return valid = briefCheckIfNumbersValid(initialNumbers);
    };

    Player.prototype.checkIfChangedFivePercentOfWeights = function(numbers) {
      var i, index, maxAllowedToChange, ref, totalChanged, valid;
      maxAllowedToChange = this.N / 20;
      totalChanged = 0;
      for (index = i = 0, ref = numbers.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
        if (numbers[index] === !this.lastValidNums[index]) {
          totalChanged += 1;
        }
      }
      return valid = totalChanged <= maxAllowedToChange;
    };

    Player.prototype.checkIfChangedValuesAreMaxTwentyPercentDifferent = function(numbers) {
      var currentTestingNum, currentValidNum, i, index, percentValue, ref;
      for (index = i = 0, ref = numbers.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
        currentTestingNum = numbers[index];
        currentValidNum = this.lastValidNums[index];
        if (currentTestingNum === !currentValidNum) {
          percentValue = currentTestingNum / currentValidNum;
          if (percentValue < 0.8 || percentValue > 1.2) {
            return false;
          }
        }
      }
      return true;
    };

    Player.prototype.checkIfLatterValuesAreValid = function(numbers) {
      if (!briefCheckIfNumbersValid(numbers)) {
        return false;
      } else if (!checkIfChangedFivePercentOfWeights(numbers)) {
        return false;
      } else if (!checkIfChangedValuesAreMaxTwentyPercentDifferent(numbers)) {
        return false;
      } else {
        return true;
      }
    };

    Player.prototype.briefCheckIfNumbersValid = function(numbers) {
      var i, len, number;
      if (numbers.length !== this.N) {
        return false;
      }
      if (!checkIfSumToCorrectValues(numbers)) {
        return false;
      }
      for (i = 0, len = numbers.length; i < len; i++) {
        number = numbers[i];
        if (number < -1) {
          return false;
        } else if (number > 1) {
          return false;
        } else if (this.utils.numberOfDecimals(number) > 2) {
          return false;
        }
      }
      return true;
    };

    Player.prototype.receivedMessage = function(message) {
      var valid;
      console.log("Player Socket Recieved Message");
      this.currentNums = this.utils.convertStringToNumArray(message);
      if (typeof this.lastValidNums === 'undefined') {
        valid = this.briefCheckIfNumbersValid(this.currentNums);
        if (valid) {
          this.lastValidNums = this.currentNums;
        } else {
          console.log("FIRST RECEIVED NUMBERS FROM PLAYER NOT VALID");
          return;
        }
      } else {
        valid = this.checkIfLatterValuesAreValid(this.currentNums);
        if (valid) {
          this.lastValidNums = this.currentNums;
        }
      }
      return this.listner.receivedCandidateFromP(this.lastValidNums);
    };

    Player.prototype.sendMessage = function(message) {
      console.log("player socket sending message");
      return this.client.write(message);
    };

    return Player;

  })();

  module.exports = Player;

}).call(this);
