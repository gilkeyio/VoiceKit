//
//  PitchTests.swift
//  AudioProcessingTests
//


import XCTest
import AVFoundation
@testable import AudioProcessing

final class PitchTests: XCTestCase {
    
    func loadTestTone(fileName: String) -> AVAudioPCMBuffer? {
        let fileType = "wav"
        // Use Bundle.module for Swift Package Manager resources
        let bundle = Bundle.module
        
        if let fileURL = bundle.url(forResource: fileName, withExtension: fileType, subdirectory: "samples") {
            return loadAudioFileIntoBuffer(url: fileURL)
        } else {
            XCTFail("File not found: \(fileName).\(fileType) in samples directory")
            return nil
        }
    }
    
    func testGetPitchForTones() {
        let testTones = ["tone_100Hz", "tone_200Hz", "tone_300Hz", "tone_400Hz"]
        let expectedPitches: [Float] = [100.0, 200.0, 300.0, 400.0] // Expected pitches for each test tone
        
        for (index, toneName) in testTones.enumerated() {
            guard let buffer = loadTestTone(fileName: toneName) else {
                continue // Skip this iteration if the buffer couldn't be loaded
            }
            
            let detectedPitch = getPitchYIN(buffer: buffer, minPitch: 20.0, maxPitch: 600.0)
            
            let tolerance = expectedPitches[index] * 0.01 // 1% of expected pitch
            
            
            XCTAssertEqual(detectedPitch!, expectedPitches[index], accuracy: tolerance, "Detected pitch for \(toneName) does not match expected value.")
        }
    }
}

