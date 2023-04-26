//
//  ChordSelectorView.swift
//  note-chord-picker
//
//  Created by Lee Angioletti on 4/25/23.
//


import SwiftUI

struct ChordSelectorView: View {
    // Define the pool of chords as an array of strings
    let chordPool: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    // Define the state variables
    @State private var selectedChords: [String] = []
    @State private var isRunning: Bool = false
    @State private var timerDuration: Int = 5
    @State private var numberOfChords: String = "3"
    @State var timeRemaining: Int?

    // Define the timer that triggers the chord selection
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//
//    var timer: Timer {
//        Timer.scheduledTimer(withTimeInterval: Double(timerDuration) ?? 5, repeats: true) { timer in
//            print("EXECUTED", timeRemaining!)
//            // If the timer is running, select n number of chords randomly from the pool
//            if isRunning {
//                let count = Int(numberOfChords) ?? 3
//                selectedChords = chordPool.shuffled().prefix(count).map { $0 }
//                // Set the time remaining based on the timer's remaining time
//                timeRemaining = timer.fireDate.timeIntervalSinceNow
//            } else {
//                // If the timer is not running, reset the time remaining to nil
//                timeRemaining = nil
//            }
//        }
//    }

    var body: some View {
        VStack {
            Text("\(selectedChords.joined(separator: " "))")
                .font(.system(size: 80))
                .fontWeight(.semibold)
                .padding()
            if let timeRemaining = timeRemaining {
                Text("Time remaining: \(Int(timeRemaining))")
                    .font(.title2)
                    .padding()
            }
            Button(isRunning ? "Stop" : "Start") {
                // Toggle the state of the timer
                isRunning.toggle()

                if isRunning {
                    // If the timer is starting, select n number of chords randomly from the pool
                    let count = Int(numberOfChords) ?? 3
                    selectedChords = chordPool.shuffled().prefix(count).map { $0 }
                    timeRemaining = timerDuration
//                    _ = timer // Start the timer
                } else {
                    // If the timer is stopping, invalidate it
//                    timer.invalidate()
                }
            }
            HStack {
                Text("Timer duration (seconds): ")
                TextField("5", value: $timerDuration, formatter: NumberFormatter())
                    .keyboardType(.numberPad) // Restrict keyboard to numeric input only
            }
            HStack {
                Text("Number of chords to select: ")
                TextField("3", text: $numberOfChords)
                    .keyboardType(.numberPad) // Restrict keyboard to numeric input only
            }



        }
        .onReceive(timer) { _ in
                        if timeRemaining == 1 {
                            let count = Int(numberOfChords) ?? 3
                            timeRemaining = timerDuration
                            selectedChords = chordPool.shuffled().prefix(count).map { $0 }
                            return
                        }
                        if isRunning {
                            timeRemaining! -= 1
                        }
                    }
    }
}


struct ChordSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ChordSelectorView()
    }
}
