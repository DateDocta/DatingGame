// Generated by CoffeeScript 1.10.0
(function() {
  var HOST, MATCHMAKER_PORT, N, PLAYER_PORT, Utils, client, connectingPort, createRandomCandidate, lastReceivedNumbers, lastReceivedScore, makeCandidate, net, parseData, parseMultipleCandidates, parseSingleCandidate, utilsL;

  console.log("In matchMaker Client");

  net = require('net');

  Utils = require("./utils");

  this.utils = new Utils;

  utilsL = new Utils;

  N = this.utils.N;

  HOST = this.utils.HOST;

  MATCHMAKER_PORT = this.utils.MATCHMAKER_PORT;

  PLAYER_PORT = this.utils.PLAYER_PORT;

  console.log("Write originanl Way" + MATCHMAKER_PORT);

  console.log("Matchmaker Port " + MATCHMAKER_PORT);

  connectingPort = {
    port: MATCHMAKER_PORT
  };

  lastReceivedNumbers = [];

  lastReceivedScore = 0;

  parseData = function(data) {
    data = data.toString();
    if (data.split("\n").length > 10) {
      return parseMultipleCandidates(data);
    } else {
      return parseSingleCandidate(data);
    }
  };

  parseSingleCandidate = function(data) {
    var index, k, ref, splitData;
    data = data.toString();
    lastReceivedNumbers = [];
    splitData = data.split(/\D/);
    for (index = k = 0, ref = N - 1; 0 <= ref ? k <= ref : k >= ref; index = 0 <= ref ? ++k : --k) {
      lastReceivedNumbers.push(splitData[index]);
    }
    return lastReceivedScore = splitData[N + 2];
  };

  parseMultipleCandidates = function(data) {
    var currentCandidate, currentCandidateScore, i, j, k, l, ref, ref1, results, splitData, totalCandidates, totalCandidatesScores, totalIterations, valuesPerCandidate;
    totalCandidates = [];
    totalCandidatesScores = [];
    currentCandidate = [];
    currentCandidateScore = 0;
    data = data.toString();
    splitData = data.split(/\D/);
    valuesPerCandidate = N + 4;
    totalIterations = splitData.length / valuesPerCandidate;
    results = [];
    for (i = k = 1, ref = totalIterations; 1 <= ref ? k <= ref : k >= ref; i = 1 <= ref ? ++k : --k) {
      for (j = l = 0, ref1 = N - 1; 0 <= ref1 ? l <= ref1 : l >= ref1; j = 0 <= ref1 ? ++l : --l) {
        currentCandidate.push(splitData[j]);
      }
      currentCandidateScore = splitData[N + 2];
      totalCandidates.push(currentCandidate);
      totalCandidatesScores.push(currentCandidateScore);
      results.push(splitData.splice(0, valuesPerCandidate));
    }
    return results;
  };

  makeCandidate = function() {
    var randomCandidate;
    return randomCandidate = createRandomCandidate();
  };

  createRandomCandidate = function() {
    var candidate, k, ref, weight;
    candidate = [];
    for (weight = k = 1, ref = N; 1 <= ref ? k <= ref : k >= ref; weight = 1 <= ref ? ++k : --k) {
      candidate.push(Math.random().toFixed(4));
    }
    return candidate;
  };

  client = net.connect(connectingPort, function() {
    return console.log("MM Client Connected on port " + connectingPort.port);
  });

  client.on('data', function(data) {
    var candidate, candidateString;
    if (data !== "gameover") {
      parseData(data);
      candidate = makeCandidate();
      candidateString = utilsL.convertNumArrayToFormattedString(candidate);
      console.log("MM Client sending data");
      return client.write(candidateString);
    }
  });

}).call(this);