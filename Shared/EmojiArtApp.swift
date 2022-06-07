//
//  EmojiArtApp.swift
//  Shared
//
//  Created by 李抗 on 2022/6/7.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document = EmojiArtDocument()
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
