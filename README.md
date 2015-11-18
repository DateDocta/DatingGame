# Dating Game
Below we have details about 

1. Slack Channel
2. Messages being passes to and from the Sockets
3. How to run the server and our clients 


**Note: You don't need to use our clients**

## Slack Channel
datedoctors.slack.com

If you notice anything wrong with the code or have any questions, feel free to make an issue on the github repo, or to write to us in the slack channel


## Data Passed Around

We are going to be passing around strings into a regular TCP socket


**N represents the numer of weighted attributes.  This number will
be given on game day and has a max of 100**

If you want to see how I parse and create these strings, you can check out the code in
the playerClient, matchMakerClient, and also in the utils file


### Player

The player will be comminicating with a socket at **port 6969**


###### Messages received from server

The player can receive one of two messages.

1. "continue"
2. "gameover"

If you receive continue, you will need to send a new Candidate following the game's stipulations


###### Messages to send to server

The only message you need to send as a Player is a string with your N weights and a space in between.

This is what I send in my client

If N = 5 and you replace letters into numbers, you could send 
"a b c d e "

### Matchmaker

The matchmaker will be comminicating with a socket at **port 9696**


###### Messages received from server

The matchmaker can also receive one of three messages based on what turn of the game.


###### Turn 1

We will be reiving 20 candidates from the server with a score attatched at the end. They will look like this

Lets say once again N was 5.  You could receive this 

"1 1 1 1 1 | a

2 2 2 2 2 | b

3 3 3 3 3 | c

. . .

20 20 20 20 20 | t"


**Note: The numbers represent the weights, then we have | bar and then the score. In the example above, the score is represented by the letter**


It will look like this


"1 1 1 1 1 | a \n2 2 2 2 2 | b \n..." 

**Tip: Easy way to parse**


If you split with regex, you can split on all non Digit chars like this.


\D means all non Digit characters

message.split(/\D/)


If you do this, index 0 to (N-1) will be all the first N scores
index at (N + 2) will be the score.  Index (N + 5) will be the index of the 
first weight of the next Candidate.  You can check the matchMakerClient in function *parseMultipleCandidates* 
to see how I do this.

##### All middle turns


After the first turn you will receive only one candiate with a score like so
"1 1 1 1 1 | a \n"

The 1's will be replaced with the weights of the last candidate that the Matchmaker sent 
to the server


The score is the a.


To get the score, you can once again split on \D and grab the element at index (N + 2)


#### End Turn


If you win, or you have already tried out 20 candidates, you will receive **"gameover"**


#### Messages to send to server


You need to send your candidate's weights with a space in between.  It is the exact
same messages you sent as the Player


**Example:**


If N = 5 and you replace letters into numbers, you could send 
"a b c d e "




## How to run

#### Run server
1. cd javascripts
2. node server.js

#### Run Basic Player Client
1. cd javascripts
2. node playerClient.js

#### Run Basic Matchmaker Client
1. cd javascripts
2. node matchmakerClient.js


*Note: If you decide you want to use coffeescript, you can go into the coffeescript directory and change the clients in there.  In matchmakerClient and playerClient, I have a **makeCandidate()** function that returns an array of numbers for a basic candidate. You can place your own logic in there if you want to use that code.*


To compile the coffeescript code, just run "./compile.sh" in a seperate terminal and your code will automatically be compiled into the javascripts directory whenever you save your code


If you want to not use coffeescript, but you do want to use the javascript client, you can just edit the makeCandidate() code directly in the appropriate javascript files


This is obviously not required



