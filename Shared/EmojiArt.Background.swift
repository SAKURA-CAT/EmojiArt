//
//  EmojiArt.Background.swift
//  EmojiArt
//
//  Created by 李抗 on 2022/6/7.
//

import Foundation


extension EmojiArtModel{
    enum Background: Equatable{
        case blank
        case url(URL)
        case imageData(Data)
        
        var url: URL?{
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imagedata: Data?{
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}
