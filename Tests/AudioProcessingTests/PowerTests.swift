//
//  PowerTests.swift
//  
//

import XCTest
import AVFoundation
@testable import AudioProcessing


final class PowerTests: XCTestCase {
    
    // File            Amplitude      Decibel Level
    //-----------------------------------------------------
    // very_low        0.1            -20.0 dBFS
    // low             0.3            -10.46 dBFS (approximately)
    // medium          0.5            -6.02 dBFS (approximately)
    // high            0.7            -3.10 dBFS (approximately)
    // very_high       1.0            0.0 dBFS
    

    
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


    func testVeryLowPower() throws {
        let expectedDbRange: ClosedRange<Float> = -25 ... -15 // expected +- 5
        guard let buffer = loadTestTone(fileName: "very_low") else {
            XCTFail("Failed to load buffer for very_low.wav")
            return
        }
        let dbLevel = calculateDecibelLevel(buffer: buffer)
        XCTAssertTrue(expectedDbRange.contains(dbLevel), "Decibel level for very_low.wav is out of expected range")
    }
    
    func testLowPower() throws {
        let expectedDbRange: ClosedRange<Float> = -15 ... -5 // expected +- 5
        guard let buffer = loadTestTone(fileName: "low") else {
            XCTFail("Failed to load buffer for low.wav")
            return
        }
        let dbLevel = calculateDecibelLevel(buffer: buffer)
        XCTAssertTrue(expectedDbRange.contains(dbLevel), "Decibel level for low.wav is out of expected range")
    }
    
    func testMediumPower() throws {
        let expectedDbRange: ClosedRange<Float> = -11 ... -1 // expected +- 5
        guard let buffer = loadTestTone(fileName: "medium") else {
            XCTFail("Failed to load buffer for medium.wav")
            return
        }
        let dbLevel = calculateDecibelLevel(buffer: buffer)
        XCTAssertTrue(expectedDbRange.contains(dbLevel), "Decibel level for medium.wav is out of expected range")
    }
    
    func testHighPower() throws {
        let expectedDbRange: ClosedRange<Float> = -8 ... 2 // expected +- 5
        guard let buffer = loadTestTone(fileName: "high") else {
            XCTFail("Failed to load buffer for high.wav")
            return
        }
        let dbLevel = calculateDecibelLevel(buffer: buffer)
        XCTAssertTrue(expectedDbRange.contains(dbLevel), "Decibel level for high.wav is out of expected range")
    }
    
    func testVeryHighPower() throws {
        let expectedDbRange: ClosedRange<Float> = -5 ... 5 // expected +- 5
        guard let buffer = loadTestTone(fileName: "very_high") else {
            XCTFail("Failed to load buffer for very_high.wav")
            return
        }
        let dbLevel = calculateDecibelLevel(buffer: buffer)
        XCTAssertTrue(expectedDbRange.contains(dbLevel), "Decibel level for very_high.wav is out of expected range")
    }



}
