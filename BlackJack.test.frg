#lang forge

open "BlackJack.frg"

//test suite for BlackJack

// pred goodValidCard{
//     all a: Card | {
//         (a.value > 1 and a.value < 12)
//     }
// }

test suite for validCard {
    // If you have tests for this predicate, put them here!
    // test expect {
    //     goodVC: {goodValidCard and validCard} is sat
    // }
    example Card1 is not validCard for {
        Card = `C0
        suit = `C0 -> `H0 
        value = `C0 -> 1
        Suit = `H0 + `D0 + `S0 + `Cl0
        Heart = `H0
        Diamond = `D0
        Spade = `S0
        Club = `Cl0
    }
        example Card2 is not validCard for {
        Card = `C0
        suit = `C0 -> `D0
        value = `C0 -> 0
        Suit = `H0 + `D0 + `S0 + `Cl0
        Heart = `H0
        Diamond = `D0
        Spade = `S0
        Club = `Cl0
    }
}

// test suite for validHand {
//     test expect{
//         badVh: {some s:State | s.player.playhand = s.dealer.playhand and validHand} is unsat
//         goodVh: {some s:State | s.player.playhand != s.dealer.playhand and validHand} is sat
//         // threecards: {some s:State | #s.player.playhand.cards = 3 and validHand and validCard} is sat
// }
// }

pred badValidDeck{
     all players:Player | players.playhand = Deck
}

pred someoneElsesDeck{
    some p1,p2:Player | p1.playhand = p2.playhand
}

test suite for validDeck{
    test expect{
        badVd: {badValidDeck and validDeck} is unsat
        notgooddeck: {someoneElsesDeck and validDeck} is unsat
    }
}

test suite for handValue {
    test expect {
        emptyHand: {some h:Hand | #h.cards = 0 and handValue[h] = 0} is sat
        maxHand: {some h:Hand, c1,c2:Card | c1 and c2 in h => c1.suit = Diamond and c2.suit = Spade and c1.value = 11 and c2.value = 11 and handValue[h] = 22} is sat
    }
}

test suite for canHit {
    test expect {
        shouldHit: {some h:Hand, c1,c2:Card | c1 and c2 in h => c1.suit = Diamond and c2.suit = Spade and c1.value = 11 and c2.value = 2 and canHit[h]} is sat
        shouldNotHit: {some h:Hand, c1,c2:Card | c1 and c2 in h => c1.suit = Diamond and c2.suit = Spade and c1.value = 11 and c2.value = 10 and canHit[h]} is unsat
    }
}
//tested in evaluator in sterling does work
test suite for hit {
    test expect {
        cardMoved: {some h:Hand | some c:Card | c in Deck.cards and hit[h] => c in h.cards and c not in Deck.cards} is sat
        handIncreased: {some h:Hand | #h.cards = 2 and hit[h] => #h.cards = 3} is sat
    }
}

test suite for stand {
    test expect {
        playerStands: {all pre:State, post:State | not canHit[pre.player.playhand] => pre.player.playhand = post.player.playhand} is sat
    }
}

test suite for makeAMove {
    test expect {
        bothHit: {all pre:State, post:State | canHit[pre.player.playhand] and canHit[pre.dealer.playhand] => #post.player.playhand.cards = 3 and #post.dealer.playhand.cards = 3} is sat
        playerStands: {all pre:State, post:State | canHit[pre.player.playhand] and not canHit[pre.dealer.playhand] => #post.player.playhand.cards = 3 and #post.dealer.playhand.cards = 2} is sat
        dealerStands: {all pre:State, post:State | not canHit[pre.player.playhand] and canHit[pre.dealer.playhand] => #post.player.playhand.cards = 2 and #post.dealer.playhand.cards = 3} is sat
        bothStand: {all pre:State, post:State | not canHit[pre.player.playhand] and not canHit[pre.dealer.playhand] => #post.player.playhand.cards = 2 and #post.dealer.playhand.cards = 2} is sat
    }
}

test suite for victor {
    test expect {
        playerWins: {some s:State | some p:Opp, d:Dealer | handValue[p.playhand] = 20 and handValue[d.playhand] = 19 and s.gs = win} is sat
        playerLoses: {some s:State | some p:Opp, d:Dealer | handValue[p.playhand] = 22 and handValue[d.playhand] = 19 and s.gs = lose} is sat
        playerTies: {some s:State | some p:Opp, d:Dealer | handValue[p.playhand] = 19 and handValue[d.playhand] = 19 and s.gs = lose} is sat
        playerWins2: {some s:State | some p:Opp, d:Dealer | handValue[p.playhand] = 19 and handValue[d.playhand] = 17 and s.gs = win} is sat
    }
}

test suite for initGame {
    test expect {
        correctSetup: {some s:State | #s.player.playhand.cards = 2 and #s.dealer.playhand.cards = 2 and #Deck.cards = 5} is sat
    }
}


