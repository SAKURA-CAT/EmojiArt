//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by 李抗 on 2022/7/7.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette
    
    var body: some View {
        Form{
            nameSection
            addEmojisSection
            removeEmojiSection
        }
        .navigationTitle("Edit \(palette.name)")
        .frame(minWidth: 300, minHeight: 350)
    }
    
    private var nameSection: some View{
        Section("Name"){
            TextField("Write the group name", text: $palette.name)
        }
    }
    
    @State private var emojisToAdd = ""
    private var addEmojisSection: some View{
        Section("Add Emojis"){
            TextField("", text: $emojisToAdd)
                .textContentType(.addressCity)
                .onChange(of: emojisToAdd){ emojis in
                    // addEmojis(emojis)
                    palette.emojis = (emojis + palette.emojis)
                        .filter{ $0.isEmoji }
                        .withNoRepeatedCharacters
                }
        }
    }
    
//    private func addEmojis(_ emojis: String){
//        palette.emojis = (emojis + palette.emojis)
//            .filter{ $0.isEmoji }
//            // todo: Handle duplicate characters
//    }
    
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emoji")) {
            let emojis = palette.emojis.withNoRepeatedCharacters.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
            .font(.system(size: 40))
        }
    }

}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(palette: .constant(PaletteStore(named: "Preview").palette(at: 4)))
            .previewLayout(.fixed(width: 300, height: 350))
    }
}
