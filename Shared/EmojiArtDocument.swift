//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by 李抗 on 2022/6/7.
//

import SwiftUI

class EmojiArtDocument: ObservableObject{
    @Published private(set) var emojiArtModel:EmojiArtModel
    init(){
        emojiArtModel = EmojiArtModel()
        emojiArtModel.addEmoji("🚀", at: (-200, 100), size: 80)
        emojiArtModel.addEmoji("😘", at: (50, -200), size: 50)
    }
    var emojis: [EmojiArtModel.Emoji] {emojiArtModel.emojis}
    
    var background: EmojiArtModel.Background {emojiArtModel.background}
    
    // MARK: - Intent(s)
    // includes setBackground addEmoji moveEmoji scaleEmoji and so on
    func setBackground(_ background:EmojiArtModel.Background){
        emojiArtModel.background = background
    }
    
    func addEmoji(_ emoji:String, x:Int, y:Int, size:CGFloat){
        emojiArtModel.addEmoji(emoji, at: (x, y), size: Int(size))
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat){
        emojiArtModel.addEmoji(emoji, at: location, size: Int(size))
    }
    
    // move emoji from one to another
    func moveEmoji(_ emoji:EmojiArtModel.Emoji, by offset:CGSize){
        if let index = emojiArtModel.emojis.index(matching: emoji){
            emojiArtModel.emojis[index].x += Int(offset.width)
            emojiArtModel.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji:EmojiArtModel.Emoji, by scale:CGFloat){
        if let index = emojiArtModel.emojis.index(matching: emoji){
            let preSize = CGFloat(emojiArtModel.emojis[index].size)
            emojiArtModel.emojis[index].size = Int((preSize*scale).rounded(.toNearestOrAwayFromZero))
        }
    }
    
    
}
