//
//  PitchTests.swift
//  AudioProcessingTests
//

//

import XCTest
import AVFoundation

final class PitchTests: XCTestCase {
    
    func loadTestTone(fileName: String) -> AVAudioPCMBuffer? {
        let fileType = "wav"
        let bundle = Bundle(for: type(of: self))
        
        if let fileURL = bundle.url(forResource: fileName, withExtension: fileType) {
            return loadAudioFileIntoBuffer(url: fileURL)
        } else {
            XCTFail("File not found: \(fileName).\(fileType) in bundle: \(bundle)")
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

