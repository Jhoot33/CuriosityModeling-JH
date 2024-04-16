# CuriosityModeling-JH

Project Objective: What are you trying to model? Include a brief description that would give someone unfamiliar with the topic a basic understanding of your goal.

I am going to model blackjack. The game consists of a table of players that all play against a dealer. The cards are dealt out to hands of two starting with the player "face up" meaning everyone knows the cards you recieve and the dealer recieves his last card face down. The goal of the game is to get closest to 21 without going over where cards are valued with the number displayed for 2-10 with Ace being valued at 1 or 11 and the rest of the face cards being valued at 10. After receiving the cards in the begining there are three possiblites. You get a card valued 10 and an Ace and the game ends and you win, the dealer gets a card valued 10 and an Ace and the game ends and you lose, or the game enters a new phase of play if no one gets 21. In this phase of play, players can either ask to hit or stay with hit giving them another card to get closer to 21 or stay with the current value of your cards. You may hit as much as you like without going over 21 or busting. After the player hits and either chooses to stay or bust the dealer is allowed the same phase of play from which they have to follow a general strategy to stand always on 17 or above. Any player with a card value greater than the dealers wins or who has gotten 21 called a blackjack wins unless the player ties with the dealer which in my model I will represent as a loss as the player failed to beat the dealer.

Model Design and Visualization: Give an overview of your model design choices, what checks or run statements you wrote, and what we should expect to see from an instance produced by the Sterling visualizer. How should we look at and interpret an instance created by your spec? Did you create a custom visualization, or did you use the default?

I have modeled a system that will produce an inital state that give a dealer and a player two unique randomly generated hands with cards from 2-11 in value.  

States - 

Init -> Setup Cards and unique Hands with 2 unique cards if anyones cards = 21 game is over 

MakeaMove -> If no win off start then check if hitting is possible and if so hit

Final -> Either someone has reached 21, Both players have reached 21

Signatures and Predicates: At a high level, what do each of your sigs and preds represent in the context of the model? Justify the purpose for their existence and how they fit together.

In my model I have Card sigs with a suit signature to make the cards unique from each other. I then put those cards into hands being sets of cards which are assigned to players. Over all of this I have a state field that has an Opp - the person playing the game and a dealer that they are playing against. In my states I keep track of the next state so that my game can flow, the players which gives me access to their hands at any state, and another field I added called gameStatus so that at any state I can adjust the game based on the card relationship between Opp and Dealer. 

As far as the predicates go I have valid Card, Hand, and Deck. These preds I can in my run statement with traces and ensure I am only generating valid cards, hands and the deck is set up properly for the game. I created a helper fun called handValue that will sum the handvalue of any player for later. 

I now have a series of predicates where I am trying to create the flow of the game. I define an inital state of every player getting two cards which have a handvalue below busting (necessary in my model as ace can't be represetned as 1 and can be dealt two 11's). I also make sure that all cards not in hands are in the Deck and the game state starts as continue. I then try and define a system for hitting with canHit defining whether or not a player should hit, hit adding a card to a hand

This loop will theorectically continue until 17 or above is reached and canhit no longer passes causing to players to stand. Once a state is reach where all players are above 17 the cards are compared to determine a victor. For this I created a system that links a state as either continue win, or loss from the players perspective. 

Testing: What tests did you write to test your model itself? What tests did you write to verify properties about your domain area? Feel free to give a high-level overview of this.

I wrote tests to check the fundamentals of creating the cards and the decks and the hands. I also spent extensive amounts of time within sterling to confirm functions like  handvalue worked and analyzing the transitions between states. 


I was having a lot of trouble implementing the testing with intergers as I kept getting strange errors that prevented me from using them in the testing suite:

[c:\Users\julli\cs\CuriosityModeling-JH\BlackJack.test.frg:9:35 (span 2)] Integer literal (12) could not be represented in the current bitwidth (-8 through 7)

This forced me to not be able to test numbers outside of this range however by constraining and checking through many instances in sterling I have confirmed that these tests would pass given I can input intergers over 7. This seemed to happen after updating Forge. Even when I comment them out they will still raise an error which has caused my testing file to be broken. 


