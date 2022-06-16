//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by 李抗 on 2022/6/7.
//

import SwiftUI

class EmojiArtDocument: ObservableObject{
    var emojis: [EmojiArtModel.Emoji] {emojiArtModel.emojis}
    
    var background: EmojiArtModel.Background {emojiArtModel.background}
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundFecthStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus{
        case idle
        case fetching
    }
    
    @Published private(set) var emojiArtModel:EmojiArtModel{
        didSet{
            autosave()
            if emojiArtModel.background != oldValue.background{
                fetchBackgorundImageDataIfNecessary()
            }
        }
    }
    
    
    init(){
        if let url = Autosave.autosaveURL, let autosaveEmojiArt = try? EmojiArtModel(url: url){
            emojiArtModel = autosaveEmojiArt
            fetchBackgorundImageDataIfNecessary()
        }else{
            emojiArtModel = EmojiArtModel()
            emojiArtModel.addEmoji("🚀", at: (-200, 100), size: 80)
            emojiArtModel.addEmoji("😘", at: (50, -200), size: 50)
        }
    }
    
    private func fetchBackgorundImageDataIfNecessary(){
        backgroundImage = nil
        switch emojiArtModel.background{
        case .url(let url):
            // fetch the url
            backgroundFecthStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)  // this will block the whole program
                DispatchQueue.main.async { [weak self] in
                    if self?.background == EmojiArtModel.Background.url(url){
                        self?.backgroundFecthStatus = .idle
                        if imageData != nil{
                            // we should only change ui in main thread
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundFecthStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = data
                sleep(2)
                DispatchQueue.main.async { [weak self] in
                    if self?.background == EmojiArtModel.Background.imageData(data){
                        self?.backgroundFecthStatus = .idle
                        self?.backgroundImage = UIImage(data: imageData)
                    }
                }
            }
        case .blank:
            break
        }
        
    }
    
    private struct Autosave{
        static let autosaveFilename = "Autosave.emojiart"
        static var autosaveURL: URL? {
            let documentDirection = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first  // in mac we also use .networkDomainMask
            return documentDirection?.appendingPathComponent(autosaveFilename)
        }
    }
    
    private func autosave(){
        if let url = Autosave.autosaveURL{
            save(to: url)
        }
    }
    
    private func save(to url: URL){
        let thisFunction = "\(String(describing: self)).\(#function)"
        do{
            let data: Data = try emojiArtModel.json()
//            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisFunction) success!")
        }catch let encodingError where encodingError is EncodingError{
            print("\(thisFunction) couldn't encode as JSON because \(encodingError):\(encodingError.localizedDescription)")
        }catch let otherError{
            print("\(thisFunction) error = \(otherError):\(otherError.localizedDescription)")
        }
    }
    
    // MARK: - Intent(s)
    // includes setBackground addEmoji moveEmoji scaleEmoji and so on
    func setBackground(_ background:EmojiArtModel.Background){
        emojiArtModel.background = background
        print("background set to \(background) ")
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
