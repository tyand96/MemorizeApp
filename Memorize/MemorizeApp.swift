//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Tyler Anderson on 7/21/23.
//

import SwiftUI

@main
struct MemorizeApp: App {
    let game = EmojiMemoryGame()
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(game: game)
        }
    }
}
