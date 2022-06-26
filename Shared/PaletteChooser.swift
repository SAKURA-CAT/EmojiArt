//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by 李抗 on 2022/6/25.
//

import SwiftUI

struct PaletteChooser: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont:Font {.system(size: emojiFontSize)}
    
    // MARK: - EnvironmentEmojis
    @EnvironmentObject var store: PaletteStore
    
    @State private var chosenPaletteIndex = 0
    
    // MARK: - view
    var body: some View {
        let palette = store.palette(at: chosenPaletteIndex)
        HStack{
            paletteControlButton
            mainBody(for: palette)
        }
        .clipped()
    }
    
    var paletteControlButton: some View{
        Button{
            withAnimation {
                chosenPaletteIndex = (chosenPaletteIndex + 1) % store.palettes.count
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
    }
    
    func mainBody(for palette: Palette) -> some View{
        HStack{
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTransition)
    }
    
    // MARK: - Transition
    private var rollTransition: AnyTransition{
        AnyTransition.asymmetric(insertion: .offset(x:0, y: emojiFontSize), removal: .offset(x: 0, y: -emojiFontSize))
    }
}

struct ScrollingEmojisView: View{
    let emojis: String
    var body: some View{
        ScrollView(.horizontal){
            HStack{
                ForEach(emojis.withNoRepeatedCharacters.map{ String($0) }, id: \.self){ emoji in
                    Text(emoji)
                        .onDrag{ NSItemProvider(object: emoji as NSString)}
                }
            }
        }
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
    }
}
