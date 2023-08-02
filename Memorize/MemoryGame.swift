//
//  MemoryGame.swift
//  Memorize
//
//  Created by Tyler Anderson on 7/25/23.
//

import Foundation


struct MemoryGame<CardContent> where CardContent: Equatable {
    private(set) var cards: Array<Card>
    
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get { cards.indices.filter({ cards[$0].isFaceUp }).oneAndOnly }
        set { cards.indices.forEach({ cards[$0].isFaceUp = ($0 == newValue) }) }
    }
    
    init(numberOfPairsOfCards: Int, createCardConent:(Int) -> CardContent) {
        cards = []
        
        // Add number of cards.
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = createCardConent(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
        
        // Shuffle the cards initially.
        shuffle()
    }
    
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched
        {
            // If the there is only one face up card.
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                // If the content of the chosen card matches the contents of the already face up card.
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                cards[chosenIndex].isFaceUp = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    
    struct Card: Identifiable {
        var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false {
            didSet {
                stopUsingBonusTime()
            }
        }
        var content: CardContent
        var id: Int
        
        // MARK: - Bonus Time
        let bonusTimeLimitSec: TimeInterval = 5

        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimitSec - faceUpTime)
        }
        var bonusPercentRemaining: Double {
            if bonusTimeLimitSec > 0 {
                return bonusTimeRemaining / bonusTimeLimitSec
            } else {
                return 0
            }
        }
        var earnedBonus: Bool {
            isMatched && (bonusTimeRemaining > 0)
        }
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && (bonusTimeRemaining > 0)
        }
        
        var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        
        var lastFaceUpDate: Date?
        var pastFaceUpTime: TimeInterval = 0
        
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            lastFaceUpDate = nil
        }
    }
}



extension Array {
    var oneAndOnly: Element? {
        if count == 1 {
            return first
        } else {
            return nil
        }
    }
}
