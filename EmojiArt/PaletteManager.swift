//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Arkasha Zuev on 07.12.2021.
//

import SwiftUI

struct PaletteManager: View {
    @EnvironmentObject var store: PaletteStore
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name).font(editMode == .active ? .largeTitle : .caption)
                            Text(palette.emojis)
                        }
                        .gesture(editMode == .active ? tap : nil)
                    }
                }
                .onDelete { indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Mange Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem { EditButton() }
                ToolbarItem(placement: .navigationBarLeading) {
//                    if isPresented, UIDevice.current.userInterfaceIdiom != .pad {
                    if isPresented {
                        Button("Close") {
//                            dismiss
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
    
    var tap: some Gesture {
        TapGesture().onEnded { _ in
            print("1")
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .environmentObject(PaletteStore(named: "Preview"))
    }
}
