//
//  EmojiArt.Background.swift
//  EmojiArt
//
//  Created by 李抗 on 2022/6/7.
//

import Foundation


extension EmojiArtModel{
    enum Background: Equatable, Codable{
        case blank
        case url(URL)
        case imageData(Data)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let url = try? container.decode(URL.self, forKey: .url){
                self = .url(url)
            }else if let imageData = try? container.decode(Data.self, forKey: .imageData){
                self = .imageData(imageData)
            }else{
                self = .blank
            }
        }
        
        enum CodingKeys: String, CodingKey{
            case url = "backgroundURL"
            case imageData
        }
        
        func encode(to encoder: Encoder) throws {
            var containter = encoder.container(keyedBy: CodingKeys.self)
            switch self{
            case .url(let url): try containter.encode(url, forKey: .url)
            case .imageData(let imageData): try containter.encode(imageData, forKey: .imageData)
            case .blank: break
            }
        }
        
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
