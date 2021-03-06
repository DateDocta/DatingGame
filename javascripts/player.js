// Generated by CoffeeScript 1.10.0
(function() {
  var Player, Utils, net, playerSocket, utilsL;

  net = require('net');

  Utils = require("./utils");

  utilsL = new Utils;

  playerSocket = net.createServer();

  Player = (function() {
    function Player() {
      this.utils = new Utils;
      this.epsilon = this.utils.EPSILON;
      this.N = this.utils.N;
      this.HOST = this.utils.HOST;
      this.PLAYER_PORT = this.utils.PLAYER_PORT;
      this.time_left_in_seconds = 120;
    }

    Player.prototype.checkIfSumToCorrectValues = function(numbers) {
      var i, len, number, totalNegativeValue, totalPositiveValue, valid;
      totalPositiveValue = 0;
      totalNegativeValue = 0;
      for (i = 0, len = numbers.length; i < len; i++) {
        number = numbers[i];
        if (number > 0) {
          totalPositiveValue += number;
        } else {
          totalNegativeValue += number;
        }
      }
      if (Math.abs(totalPositiveValue - 1) < this.epsilon && Math.abs(totalNegativeValue + 1) < this.epsilon) {
        valid = true;
      } else {
        console.log("Received an invalid Candidate from Player");
        console.log("Total positive value is " + totalPositiveValue);
        console.log("Total negative value is " + totalNegativeValue);
        console.log("Epsilon is " + utilsL.epsilon);
        valid = false;
      }
      return valid;
    };

    Player.prototype.addListener = function(listener) {
      this.listener = listener;
      return console.log("Player added Listener");
    };

    Player.prototype.checkIfInitialNumbersAreValid = function(initialNumbers) {
      var valid;
      return valid = this.briefCheckIfNumbersValid(initialNumbers);
    };

    Player.prototype.checkIfChangedFivePercentOfWeights = function(numbers) {
      var i, index, maxAllowedToChange, ref, totalChanged, valid;
      maxAllowedToChange = this.N / 20;
      totalChanged = 0;
      for (index = i = 0, ref = numbers.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
        if (numbers[index] !== this.initialValidNums[index]) {
          totalChanged += 1;
        }
      }
      return valid = totalChanged <= maxAllowedToChange;
    };

    Player.prototype.checkIfChangedValuesAreMaxTwentyPercentDifferent = function(numbers) {
      var currentTestingNum, currentValidNum, i, index, percentValue, ref;
      for (index = i = 0, ref = numbers.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
        currentTestingNum = numbers[index];
        currentValidNum = this.initialValidNums[index];
        if (currentTestingNum !== currentValidNum) {
          percentValue = currentTestingNum / currentValidNum;
          if (percentValue < 0.8 || percentValue > 1.2) {
            return false;
          }
        }
      }
      return true;
    };

    Player.prototype.checkIfLatterValuesAreValid = function(numbers) {
      if (!this.briefCheckIfNumbersValid(numbers)) {
        return false;
      } else if (!this.checkIfChangedFivePercentOfWeights(numbers)) {
        return false;
      } else if (!this.checkIfChangedValuesAreMaxTwentyPercentDifferent(numbers)) {
        return false;
      } else {
        return true;
      }
    };

    Player.prototype.briefCheckIfNumbersValid = function(numbers) {
      var i, len, number;
      if (numbers.length !== this.N) {
        console.log("Length Incorrect: length is " + numbers.length);
        return false;
      }
      if (!this.checkIfSumToCorrectValues(numbers)) {
        console.log("Sum incorrect");
        return false;
      }
      for (i = 0, len = numbers.length; i < len; i++) {
        number = numbers[i];
        if (number < -1) {
          console.log("Number is less than -1, it is " + number);
          return false;
        } else if (number > 1) {
          console.log("Number is greater than 1, it is " + number);
          return false;
        } else if (utilsL.numberOfDecimals(number) > 2) {
          console.log("Number has too many decimals, it is " + number);
          return false;
        }
      }
      return true;
    };

    Player.prototype.toString = function() {
      return console.log("Player ToString");
    };

    Player.prototype.receivedMessage = function(message) {
      var time_message_received, total_turnaround_time, valid;
      this.currentNums = utilsL.convertStringToNumArray(message);
      if (typeof this.lastValidNums === 'undefined') {
        valid = this.briefCheckIfNumbersValid(this.currentNums);
        if (valid) {
          this.lastValidNums = this.currentNums;
          this.initialValidNums = this.currentNums;
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
      time_message_received = new Date().getTime();
      total_turnaround_time = (time_message_received - this.time_message_sent) / 1000;
      if (isNaN(total_turnaround_time)) {
        total_turnaround_time = 0;
      }
      this.time_left_in_seconds = Math.ceil(this.time_left_in_seconds - total_turnaround_time);
      console.log("Time left for Player in seconds: " + this.time_left_in_seconds);
      return this.listener.receivedCandidateFromP(this.lastValidNums);
    };

    Player.prototype.sendMessage = function(message) {
      this.client.write(message);
      return this.time_message_sent = new Date().getTime();
    };

    Player.prototype.startServer = function() {
      this.server = playerSocket;
      this.server.on('connection', (function(_this) {
        return function(client) {
          _this.client = client;
          _this.listener.connectedToP();
          return _this.client.on('data', function(data) {
            return _this.receivedMessage(data);
          });
        };
      })(this));
      this.server.listen(this.PLAYER_PORT);
      return console.log("Player Port Started on port " + this.PLAYER_PORT);
    };

    Player.prototype.timed_out = function() {
      return this.time_left_in_seconds < 0;
    };

    return Player;

  })();

  module.exports = Player;

}).call(this);
