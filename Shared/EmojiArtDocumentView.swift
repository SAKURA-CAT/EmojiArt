//
//  ContentView.swift
//  Shared
//
//  Created by 李抗 on 2022/6/7.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document:EmojiArtDocument
    
    let defaultEmojiFontSize: CGFloat = 40
    var body: some View {
        VStack(spacing: 0){
            documentBody
            palette
        }
    }
    
    var documentBody: some View{
        GeometryReader{ geometry in
            ZStack{
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .position(convertFromEmojiCoordinates((0, 0), in: geometry))
                        .scaleEffect(zoomScale)
                )
                .gesture(doubleTapToZoom(in: geometry.size))
                if document.backgroundFecthStatus == .fetching{
                    ProgressView().scaleEffect(2)
                }else{
                    ForEach(document.emojis){ emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .position(position(for: emoji, in: geometry))
                            .scaleEffect(zoomScale)
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil){ providers, location in
                return drop(providers: providers, at: location, in: geometry)
            }
            .gesture(zoomGestrue())
        }
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool{
        var found = providers.loadObjects(ofType: URL.self){ url in
            document.setBackground(EmojiArtModel.Background.url(url.imageURL))
        }
        
        if !found{
            found = providers.loadObjects(ofType: UIImage.self){ image in
                if let data = image.jpegData(compressionQuality: 1.0){
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found{
            found = providers.loadObjects(ofType: String.self){ string in
                if let emoji = string.first, emoji.isEmoji{
                    document.addEmoji(String(emoji),
                                      at: convertToEmojiCoordinates(location, in: geometry),
                                      size: defaultEmojiFontSize / zoomScale
                    )
                }
            }
        }
        return found
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat{
        CGFloat(emoji.size)
    }
    
    @State private var ifFit: Bool = false  // define: ifFit is true -> now the image is fit the screen;
    
    @State private var SteadyZoomScale: CGFloat = 1
    
    @GestureState private var gestureZooomScale: CGFloat = 1
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture{
         TapGesture(count: 2)
            .onEnded { () in
                withAnimation {
                    doubleTapZoomFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private var zoomScale: CGFloat{
        SteadyZoomScale * gestureZooomScale
    }
    
    private func zoomGestrue() -> some Gesture{
        MagnificationGesture()
            .updating($gestureZooomScale){ latestGestureScale, ourGestrueStateInOut, transaction in
                ourGestrueStateInOut = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                SteadyZoomScale *= gestureScaleAtEnd
                if SteadyZoomScale != 1{
                    ifFit = false
                }
            }
    }
    
    // zoom the background to fit the screen
    // when we double tap the screen, the image will be zoom to fit the screen
    // when we double tape again, the image will be show as origin one
    // by the way, both the position and the size of emoji can be fit at same time
    private func doubleTapZoomFit(_ image: UIImage?, in size: CGSize){  // screen size
        if let image = image, image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0{
            if !ifFit{
                let hZoom = size.width / image.size.width
                let vZoom = size.height / image.size.height
                SteadyZoomScale = min(hZoom, vZoom)
                ifFit = true
            }else{
                SteadyZoomScale = 1
                ifFit = false
            }
        }
    }
    
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint{
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int){
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - center.x) / zoomScale,
            y: (location.y - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint{
        let center = geometry.frame(in: .local).center
         return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale,
            y: center.y + CGFloat(location.y) * zoomScale
         )
    }
    
    
    var palette: some View{
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    let testEmojis = "😀😷🦠💉👻👀🐶🌲🌎🌞🔥🍎⚽️🚗🚓🚲🛩🚁🚀🛸🏠⌚️🎁🗝🔐❤️⛔️❌❓✅⚠️🎶➕➖🏳️"
}

struct ScrollingEmojisView: View{
    let emojis: String
    var body: some View{
        ScrollView(.horizontal){
            HStack{
                ForEach(emojis.map{ String($0) }, id: \.self){ emoji in
                    Text(emoji)
                        .onDrag{ NSItemProvider(object: emoji as NSString)}
                }
            }
        }
    }
}















struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
