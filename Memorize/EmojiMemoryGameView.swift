//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by Tyler Anderson on 7/21/23.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    
    let aspectRatio: CGFloat = 2/3
    
    @ObservedObject var game: EmojiMemoryGame
    
    @Namespace private var dealingNamespace
    
    @State private var dealt = Set<Int>()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            deckBody
            
            VStack {
                gameBody
                
                HStack {
                    restartButton
                    Spacer()
                    shuffleButton
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: aspectRatio) { card in
            if isNotDealt(card) || (card.isMatched && !card.isFaceUp) {
                Color.clear
            } else {
                CardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation {
                            game.choose(card)
                        }
                    }
            }
        }
        .foregroundColor(CardConstants.color)
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isNotDealt)) {card in
                CardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(CardConstants.color)
        .onTapGesture {
            // Deal the cards
            for card in game.cards {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    var shuffleButton: some View {
        Button("Shufle") {
            withAnimation {
                game.shuffle()
            }
        }
    }
    
    var restartButton: some View {
        Button("Restart") {
            withAnimation {
                dealt = []
                game.restart()
            }
        }
    }
    
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isNotDealt(_ card: EmojiMemoryGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: {$0.id == card.id}) {
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return .easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double {
        -Double(game.cards.firstIndex(where: {$0.id == card.id}) ?? 0)
    }
    
    private struct CardConstants {
        static let color = Color.red
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealtHeight: CGFloat = 90
        static let undealtWidth: CGFloat = undealtHeight * aspectRatio
    }
}

struct CardView: View {
    private let card: EmojiMemoryGame.Card
    
    @State private var animatedBonusRemaining: Double = 0
    
    init(_ card: EmojiMemoryGame.Card) {
        self.card = card
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                let degrees: Double = card.isMatched ? 360 : 0
                
                if card.isConsumingBonusTime {
                    let angleDiff: Angle = Angle(degrees: animatedBonusRemaining * 360)
                    let endAngle: Angle = DrawingConstants.startAngle - angleDiff
                    Pie(startAngle: DrawingConstants.startAngle, endAngle: endAngle).padding(5).opacity(0.5)
                        .onAppear {
                            animatedBonusRemaining = card.bonusPercentRemaining
                            withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                animatedBonusRemaining = 0
                            }
                        }
                } else {
                    let angleDiff: Angle = Angle(degrees: card.bonusPercentRemaining * 360)
                    let endAngle: Angle = DrawingConstants.startAngle - angleDiff
                    Pie(startAngle: DrawingConstants.startAngle, endAngle: endAngle).padding(5).opacity(0.5)
                }


                Text(card.content)
                    .rotationEffect(Angle(degrees: degrees))
                    .animation(.easeInOut(duration: 1), value: degrees)
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        (min(size.width, size.height) * DrawingConstants.fontScale) / DrawingConstants.fontSize
    }
    
    private func font(in size: CGSize) -> Font {
        Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.7
        static let fontSize: CGFloat = 32
        static let startAngle: Angle = Angle(degrees: -90)
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = EmojiMemoryGame()
        
        viewModel.choose(viewModel.cards.first!)
        
        return EmojiMemoryGameView(game: viewModel)
            .preferredColorScheme(.light)
        
//        EmojiMemoryGameView(game: viewModel)
//            .preferredColorScheme(.dark)
    }
}




