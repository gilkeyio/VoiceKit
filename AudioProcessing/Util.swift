//
//  Util.swift
//  AudioProcessing
//
//

import Foundation
import AVFoundation


func loadAudioFileIntoBuffer(url: URL) -> AVAudioPCMBuffer? {
    do {
        // Load the audio file
        let audioFile = try AVAudioFile(forReading: url)

        // Get the audio format and frame count
        let audioFormat = audioFile.processingFormat
        let audioFrameCount = UInt32(audioFile.length)

        // Create a buffer with the same format and frame capacity as the audio file
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount) else {
            print("Failed to create audio buffer.")
            return nil
        }

        // Read the audio data into the buffer
        try audioFile.read(into: buffer)

        return buffer
    } catch {
        print("Error loading audio file: \(error)")
        return nil
    }
}
