//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Arkasha Zuev on 09.11.2021.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    @Published var backgroungImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var backgroung: EmojiArtModel.Background { emojiArt.background }
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetchin
    }
    
    init() {
        emojiArt = EmojiArtModel()
        emojiArt.addEmoji("😂", at: (-200, -100), size: 80)
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroungImage = nil
        switch emojiArt.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetchin
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            self?.backgroungImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroungImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}
