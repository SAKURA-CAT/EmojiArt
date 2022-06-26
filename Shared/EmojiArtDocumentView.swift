//
//  ContentView.swift
//  Shared
//
//  Created by 李抗 on 2022/6/7.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document:EmojiArtDocument
    
    // MARK: - Basic value
    let defaultEmojiFontSize: CGFloat = 40
    
    // MARK: - View body
    var body: some View {
        VStack(spacing: 0){
            documentBody
            PaletteChooser(emojiFontSize: defaultEmojiFontSize)
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
            .gesture(panGesture().simultaneously(with: zoomGestrue()))
        }
    }
    
    // MARK: - Intent(s)
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat{
        CGFloat(emoji.size)
    }
    
    // caculate the emoji posion relative to the screen
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint{
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    // convert screen position to EmojiCoordinates
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int){
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint{
        let center = geometry.frame(in: .local).center
         return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
         )
    }
    
    // MARK: - Gesture: Single finger droping
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
    
    // MARK: - Gesture: Double finger scaling
    @State private var SteadyZoomScale: CGFloat = 1
    
    @GestureState private var gestureZooomScale: CGFloat = 1
    
    private var zoomScale: CGFloat{
        SteadyZoomScale * gestureZooomScale
    }
    
    private func zoomGestrue() -> some Gesture{
        MagnificationGesture()
            .updating($gestureZooomScale){ latestGestureScale, gestureZooomScale, transaction in
                gestureZooomScale = latestGestureScale  // equal to gestureZooomScale
            }
            .onEnded { gestureScaleAtEnd in
                SteadyZoomScale *= gestureScaleAtEnd
                if SteadyZoomScale != 1{
                    ifFit = false
                }
            }
    }
    
    // MARK: - Gesture: Double tap scaling
    @State private var ifFit: Bool = false  // define: ifFit is true -> now the image is fit the screen;
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture{
         TapGesture(count: 2)
            .onEnded { () in
                withAnimation {
                    doubleTapZoomFit(document.backgroundImage, in: size)
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
                steadyStatePanOffset = .zero
                ifFit = true
            }else{
                SteadyZoomScale = 1
                ifFit = false
            }
            steadyStatePanOffset = .zero
        }
    }
    
    // MARK: - Gesture: Single finger translation the picture
    // 2D offset
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture{
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded{  finalGragGesture in
                steadyStatePanOffset = steadyStatePanOffset + (finalGragGesture.translation / zoomScale)
            }
    }
}


// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
