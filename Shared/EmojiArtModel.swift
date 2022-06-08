//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by 李抗 on 2022/6/7.
//

import Foundation
// EmojiArt's main logical model

struct EmojiArtModel{
    var background = Background.blank
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Hashable {
        var text: String
        // we use Int because we wan't to different model from view
        var x: Int  // offset from the center
        var y: Int  // offset from the center
        var size: Int
        let id: Int
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int){
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    init(){}
    
    private var uniqueEmojiId = 0
    mutating func addEmoji(_ text:String, at location: (x:Int, y:Int), size:Int){
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
    
}
