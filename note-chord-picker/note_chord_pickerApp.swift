//
//  note_chord_pickerApp.swift
//  note-chord-picker
//
//  Created by Lee Angioletti on 4/25/23.
//

import SwiftUI

@main
struct note_chord_pickerApp: App {
    @StateObject private var store = NoteChordPoolStore()
    
    var body: some Scene {
        WindowGroup {
            let selectedChords = randomlySelectItems(items: store.pools, drawSize: store.drawSize, aggregatePools: store.aggregatePools)
            ChordSelectorView(selectedChords: selectedChords, aggregatePools: $store.aggregatePools, timerDuration: $store.timerDuration, drawSize: $store.drawSize, items: $store.pools) {
                Task {
                    do {
                        try await store.save(pools: store.pools)
                        try await store.save(timerDuration: store.timerDuration)
                        try await store.save(drawSize: store.drawSize)
                        try await store.save(aggregatePools: store.aggregatePools)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .task {
                do {
                    try await store.load()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
