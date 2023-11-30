//
//  ContentView.swift
//  Resonance
//


import SwiftUI
import AVFoundation
import AudioProcessing

struct ContentView: View {
    @State private var pitch: Float = 0.0
    @State private var power: Float = 0.0
    @State private var isRecording = false
    @State private var recentPitches: [Float] = []
    private let audioEngine = AVAudioEngine()
    private let maxRecentPitches = 10 // Determines the smoothing window size
  
    var body: some View {
        VStack {           
            Text("Pitch: \(pitch) Hz")
            Text("Power: \(power) dBFS")
            Button(isRecording ? "Stop Recording" : "Start Recording") {
                isRecording ? stopRecording() : startRecording()
            }
        }
    }
    
    func updatePitch(with newPitch: Float) {
        recentPitches.append(newPitch)
        
        // Remove the oldest pitch if the buffer exceeds the maximum size
        if recentPitches.count > maxRecentPitches {
            recentPitches.removeFirst()
        }
        
        // Calculate the average pitch
        let sum = recentPitches.reduce(0, +)
        let averagePitch = sum / Float(recentPitches.count)
        
        self.pitch = averagePitch
    }
    
    func startRecording() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            DispatchQueue.main.async {
                let newPitch = AudioProcessing.getPitchYIN(buffer: buffer, minPitch: 60, maxPitch: 250, silenceThresholdDb: -40.0) ?? -1
                self.updatePitch(with: newPitch)
                self.power = AudioProcessing.calculateDecibelLevel(buffer: buffer)
            }
        }
        do {
            try audioEngine.start()
        } catch {
            print("Could not start audio engine: \(error)")
        }
        
        isRecording = true
    }
    
    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        isRecording = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
