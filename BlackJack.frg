#lang forge

//implementation of blackjack in Forge

sig Card {
    value: one Int,
    suit: one Suit
    }

abstract sig Suit{}
one sig Heart, Diamond, Club, Spade extends Suit {}

sig Hand {
    cards: set Card
}

one sig Deck extends Hand{}

sig Player {
    playhand: one Hand
}

one sig Dealer extends Player{}
one sig Opp extends Player{}

sig State{
    next: lone State,
    dealer: one Dealer,
    player: one Opp,
    deckcards: one Deck,
    gs: one gameStatus
}

abstract sig gameStatus{}
one sig win extends gameStatus{}
one sig continue extends gameStatus{}
one sig lose extends gameStatus{}


//all cards are 2-11 in value, in one hand and is unique
pred validCard{
    // some c:Card | c in Deck.cards or c in Dealer.playhand.cards or c in Opp.playhand.cards
    //all cards have a value between 1 and 11
    all c:Card | (c.value >= 2 and c.value <= 11) 
    // all h1,h2:Hand | h1 != h2 => not reachable[h2,h1,cards] and not reachable[h1,h2,cards]
    //all cards are unique in either suit or value
    all disj c1, c2: Card | c1 != c2 => (c1.value != c2.value or c1.suit != c2.suit)
}
pred validHand{
    //hand must belong to a player
    // all h:Hand | some p:Player | p.playhand = h
    //all players have distinct hands at all times
    all s:State | s.player.playhand != s.dealer.playhand
    //all players have distinct hands at all times
    all s:State | s.player.playhand.cards & s.dealer.playhand.cards = none
    //cards can only be in one hand at a time 
    all s:State | all c:Card | (c in s.player.playhand.cards => c not in s.dealer.playhand.cards) and (c in s.dealer.playhand.cards => c not in s.player.playhand.cards)
}

//Create a deck with cards to deal to players and dealers if they need to hit
pred validDeck{
    validCard
    // some c:Card | c in Deck.cards
    //deck cannot belong to a player
    all players:Player | players.playhand != Deck
    //cards in hands are not in the deck
    // all c:Card | c not in s.dealer.playhand.cards and c not in s.player.playhand.cards => c in Deck.cards
    //no overlap
    all s:State | all p:Player | p.playhand.cards & s.deckcards.cards = none
    //The deck has x cards
    #Deck.cards = 5
    }

//find value of hand
fun handValue[h:Hand]:one Int{
    //calculate the value of the hand
    sum[h.cards.value]
}

pred initGame[s:State]{
    //initialize the game with a dealer and two players
    //every player has to start with a hand of two cards
    all p:Player | #p.playhand.cards = 2 and handValue[p.playhand] < 22
    all c:Card | c not in s.dealer.playhand.cards and c not in s.player.playhand.cards => c in Deck.cards
    //set game continue
    s.gs = continue

    //deal two cards to the dealer in the next state
    // some c1,c2:Card | c1 in Deck.cards and c2 in Deck.cards and c1 != c2 => {
    //    s.next.dealer.playhand.cards = s.dealer.playhand.cards + c1 + c2
    //     s.next.deckcards.cards = s.deckcards.cards - c1 - c2
    // }

    // //deal two cards to the player in the next state
    // some c3,c4:Card | c3 in Deck.cards and c4 in Deck.cards and c3 != c4 => {
    //     s.next.player.playhand.cards = s.player.playhand.cards + c3 + c4
    //     s.next.deckcards.cards = s.deckcards.cards - c3 - c4
    // }
}

pred canHit[h:Hand]{
    //check if the player can hit
    handValue[h] < 17
}

pred hit[h:Hand]{
    //add a card to the hand
    validCard
    //some card in and deck and not in the hand
    some c:Card | c in Deck.cards and c not in h.cards => { 
            //remove card from deck
            Deck.cards = Deck.cards - c
            //add card to hand
            h.cards = h.cards + c
            //hand must be more than two cards after a hit
            #h.cards > 2
    }
}

//pass and move to next state
pred stand[pre:State, post:State]{
    //stand and move to the next player
    not canHit[pre.dealer.playhand] => pre.dealer.playhand = post.dealer.playhand
    not canHit[pre.player.playhand] => pre.player.playhand = post.player.playhand
}

pred makeAMove[pre:State, post:State]{
    //stand or hit
    //Check if winner in inital state then
    canHit[pre.dealer.playhand]=> hit[post.dealer.playhand] else stand[pre,post]
    canHit[pre.player.playhand]=> hit[post.player.playhand] else stand[pre,post]
    }

//defines all states final outcomes
//player wins after hitting to above 17 and hasnt busted and has a hand value greater than the dealers
//player loses after hitting to above 17 and hasnt busted and has a hand value less than the dealers
//player loses after hitting and busting and player wins after dealer busts

pred victor[s:State]{
    //if the dealer has a hand value greater than 21, the dealer loses
    some p:Opp| some d:Dealer | {
        //wins when player hasnt busted and player has a handvalue greater or equal to 17 and that value is more than the dealers 
        (handValue[p.playhand] < 22 and handValue[p.playhand] >= 17 and handValue[p.playhand] >= handValue[d.playhand] => s.gs = win) or
        //loses when hand value is greater than 17 but less than the dealers
        (handValue[p.playhand] < 22 and handValue[p.playhand] >= 17 and handValue[p.playhand] < handValue[d.playhand] => s.gs = lose) or 
        //busting condition -> if player busts they lose if dealer busts they win
        ((handValue[p.playhand] > 21 => s.gs = lose) or (handValue[d.playhand] > 21 => s.gs = win))
    }
}

pred traces{
    some inital, end:State | {
    victor[end]
    initGame[inital]
    // all t:State | {
    //     t.gs = continue or t.gs = win or t.gs = lose
    //     t.gs = win or t.gs = lose => not some t.next
    //     t!=inital => reachable[t,inital,next]
    //     some t.next => hit[t.player.playhand]
    // }
}
// all s:State | {
//     victor[s] => no s.next
// }
}

run {validCard
    validHand
    validDeck
    traces} for 1 Dealer, 1 Deck, 1 Opp, 19 Card, 2 Player, 6 Int, 1 win, 1 lose, 10 State for {next is linear}



        // end and winInit[init] => no end.next 
        
        //fix winit to not constrain blackjack
        // winInit[init] => no end.next
        // all t:State | {
        //     t!=init => reachable[t,init,next]
        // }
    
    // all s:State | {
    //     win[s] => no s.next
    //     not win[s] => midPlay[s.next]
    //     // not win[s] => s.next and midPlay
    // }