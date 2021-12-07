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
            scheduleAutosave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    @Published var backgroungImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    private var autosaveTimer: Timer?
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var backgroung: EmojiArtModel.Background { emojiArt.background }
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetchin
        case failed(URL)
    }
    
    private func scheduleAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
            self.autosave()
        }
    }
    
    private struct Autosave {
        static let coalescingInterval = 5.0
        static let filename = "Autosaved.emojiart"
        static var url: URL? {
            let documentDidectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDidectory?.appendingPathComponent(filename)
        }
    }
    
    func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisfunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArt.json()
            try data.write(to: url)
            print("\(thisfunction) success")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisfunction) couldn't encode EmojiArt as JSON because \(encodingError.localizedDescription)")
        } catch {
            print("\(thisfunction) error = \(error)")
        }
    }
    
    init() {
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
            emojiArt = autosavedEmojiArt
            fetchBackgroundImageDataIfNecessary()
        } else {
            emojiArt = EmojiArtModel()
            //        emojiArt.addEmoji("😂", at: (-200, -100), size: 80)
        }
    }
    
    // MARK: - Background
    
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
                        if self?.backgroungImage == nil {
                            self?.backgroundImageFetchStatus = .failed(url)
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
