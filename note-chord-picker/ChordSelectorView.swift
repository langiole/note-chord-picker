//
//  ChordSelectorView.swift
//  note-chord-picker
//
//  Created by Lee Angioletti on 4/25/23.
//


import SwiftUI


public protocol PianoKeyboardDelegate: AnyObject {
    func pianoKeyUp(_ keyNumber: Int)
    func pianoKeyDown(_ keyNumber: Int)
}

struct ChordSelectorView: View {
    // Define the pool of chords as an array of strings

    // Define the state variables
    @State public var selectedChords: [String]
    @State private var isRunning: Bool = false
    @State var timeRemaining: Int?
    @Binding var aggregatePools: Bool
    
    @Environment(\.scenePhase) private var scenePhase

    private let audioEngine = AudioEngine()
    

    // Define the timer that triggers the chord selection
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Binding public var timerDuration: Int
    @Binding public var drawSize: Int
    @Binding public var items: [NoteChordPool]
    
    @State private var showPopup = false

    @FocusState private var isChordSelectorFocused: Bool
    @FocusState private var isTimerSelectorFocused: Bool
    
    let saveAction: ()->Void



    var body: some View {
        NavigationStack {
            VStack {
                
                VStack {
                    Text("\(selectedChords.joined(separator: " "))")
                        .font(.system(size: 80))
                        .fontWeight(.semibold)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding()
                    Text("Time remaining: \(Int(timeRemaining ?? timerDuration))")
                        .font(.title2)
                        .padding()
                    
                    Button {
                        // Toggle the state of the timer
                        isRunning.toggle()
                        
                        audioEngine.pianoKeyDown(60)
                        
                        if isRunning {
                            // If the timer is starting, select n number of chords randomly from the pool
                            selectedChords = randomlySelectItems(items: items, drawSize: drawSize, aggregatePools: aggregatePools)
                            timeRemaining = timerDuration
                            //                    _ = timer // Start the timer
                        } else {
                            // If the timer is stopping, invalidate it
                            //                    timer.invalidate()
                        }
                    } label: {
                        Text(isRunning ? "Stop timer" : "Start timer")
                            .padding(.horizontal, 50)
                            .frame(height: 44)
                    }
                    .tint(isRunning ? Color(.systemRed) : Color(.systemGreen))
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding()
                }
                .padding()
                
                VStack   {
                    
                    HStack {
                        Text("Timer duration (seconds): ")
                        TextField("5", value: $timerDuration, formatter: NumberFormatter())
                            .padding()
                            .keyboardType(.numberPad)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(10)
                            .fixedSize()
                            .focused($isTimerSelectorFocused)
                            .onTapGesture {
                                isTimerSelectorFocused = true
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                if let textField = obj.object as? UITextField {
                                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                }
                            }
                    }
                    HStack {
                        Text("Number of chords to select: ")
                        TextField("\(drawSize)", value: $drawSize, formatter: NumberFormatter())
                            .padding()
                            .keyboardType(.numberPad)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(10)
                            .fixedSize()
                            .focused($isChordSelectorFocused)
                            .onTapGesture {
                                isChordSelectorFocused = true
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                if let textField = obj.object as? UITextField {
                                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                }
                            }
                    }
                    
                    HStack {
                        Spacer()
                        Text("Aggregate pools:")
                        Toggle("", isOn: $aggregatePools)
                            .labelsHidden()
                        Spacer()
                    }
                    
                    
                    NavigationLink(destination: ItemsView(items: $items)) {
                        let numberOfActivePools = items.filter { $0.active }.count
                        Text(numberOfActivePools == 0 ? "Select pools" : numberOfActivePools > 1 ? "Selected \(numberOfActivePools) pools" : "Selected \(numberOfActivePools) pool")
                            .padding()
                    }
                }
            }
            .onReceive(timer) { _ in
                if timeRemaining == 1 {
                    timeRemaining = timerDuration
                    selectedChords = randomlySelectItems(items: items, drawSize: drawSize, aggregatePools: aggregatePools)
                    return
                }
                if isRunning {
                    timeRemaining! -= 1
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { saveAction() }
        }
        .onAppear() {
            audioEngine.start()
        }
    }
}

func randomlySelectItems(items: [NoteChordPool], drawSize: Int, aggregatePools: Bool) -> [String] {
    var lake: [NoteChordPool]
    if (aggregatePools) {
        lake = items.filter { $0.active }
    } else {
        lake = items.filter { $0.active }.shuffled().prefix(1).map { $0 }
    }
    return lake.flatMap({$0.pool}).shuffled().prefix(drawSize).map { $0 }
}


    

struct MultipleSelectionRow: View {
    @State private var showingDeleteAlert = false

   let item: NoteChordPool
   let isSelected: Bool
    @Binding public var items: Set<NoteChordPool>
    @Binding public var showingSheet: Bool
    @Environment(\.editMode) private var editMode


    let action: () -> Void

   var body: some View {
       Button(action: action) {
           withAnimation {
               HStack {
                   if editMode?.wrappedValue.isEditing == true {
                       Button(role: .destructive, action: {
                           showingDeleteAlert = true
                       }, label: {
                           Image(systemName: "minus.circle.fill")
                               .foregroundColor(.red)
                       })
                   }
                   
                   Text(item.name)
                   
                   if isSelected && editMode?.wrappedValue.isEditing != true {
                       Spacer()
                       Image(systemName: "checkmark")
                   }
               }
           }
       }
//       .swipeActions(allowsFullSwipe: false) {
//           Button("Delete", role: .destructive) {
//
//           }
//       }
       .deleteDisabled(editMode?.wrappedValue.isEditing != true)
   }
}

struct ChordSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        let selectedChords = randomlySelectItems(items: NoteChordPool.sampleData, drawSize: 3, aggregatePools: true)
        ChordSelectorView(selectedChords: selectedChords, aggregatePools: .constant(true), timerDuration: .constant(5), drawSize: .constant(3), items: .constant(NoteChordPool.sampleData), saveAction: {})
    }
}
