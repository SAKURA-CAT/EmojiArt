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
    
    @State private var managing = false
    
//    @State private var editing = false
    
    @State private var paletteToEdit: Palette?
    
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
        .contextMenu{contextMenu}
    }
    
    func mainBody(for palette: Palette) -> some View{
        HStack{
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTransition) 
//        .popover(isPresented: $editing){
//            PaletteEditor(palette: $store.palettes[chosenPaletteIndex])
//        }
        // we use a more flexiable way to create a popover
        .popover(item: $paletteToEdit){ palette in
            PaletteEditor(palette: $store.palettes[palette])
        }
        .sheet(isPresented: $managing){
            PaletteManager()
        }
    }
    
    // MARK: - Transition
    private var rollTransition: AnyTransition{
        AnyTransition.asymmetric(insertion: .offset(x:0, y: emojiFontSize), removal: .offset(x: 0, y: -emojiFontSize))
    }
    
    // MARK: - contextMenu

    
    @ViewBuilder
    var contextMenu: some View{
        AnimatedActionButton(title: "Edit", systemImage: "pencil"){
//            editing = true
            paletteToEdit = store.palette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus"){
            store.insertPalette(named: "New", emojis: "", at: chosenPaletteIndex)
//            editing = true
            paletteToEdit = store.palette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle"){
            chosenPaletteIndex = store.removePalette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3"){
            managing = true
        }
        gotoMenu
    }
    
    var gotoMenu: some View{
        Menu{
            ForEach(store.palettes){ palette in
                AnimatedActionButton(title: palette.name){
                    if let index = store.palettes.index(matching: palette){
                        chosenPaletteIndex = index
                    }
                }
            }
        }label: {
            Label("goto", systemImage: "text.insert")
        }
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
