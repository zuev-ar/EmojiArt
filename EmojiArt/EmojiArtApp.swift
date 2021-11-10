//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Arkasha Zuev on 09.11.2021.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
