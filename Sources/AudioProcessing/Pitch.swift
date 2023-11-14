//
//  Pitch.swift
//  AudioProcessing
//
//
//

import Foundation
import AVFoundation
import Accelerate


public func getPitchYIN(buffer: AVAudioPCMBuffer, minPitch: Float, maxPitch: Float) -> Float? {
    // Process the buffer here
    
    // Step 1: Convert Audio Buffer to an Array of Floats
    // Convert the incoming audio buffer to an array of floats for processing.
    // This step is crucial as YIN operates on sample data directly.
    let audioSamples = convertBufferToFloatArray(buffer: buffer)
    
    if audioSamples.isEmpty {
        return nil
    }
    
    // Step 2: Implement the Difference Function
    // The difference function calculates the difference between the signal and its shifted version.
    // Loop through the buffer and implement the difference function as defined by YIN.
    let differenceFunction = calculateDifferenceFunction(audioSamples: audioSamples, sampleRate: Float(buffer.format.sampleRate), minPitch: minPitch, maxPitch: maxPitch)
    
    
    // Step 3: Calculate the Cumulative Mean Normalized Difference Function
    // Calculate the cumulative mean on the difference function to help in thresholding.
    // This step normalizes the difference function.
    let cmndf = calculateCMNDF(differenceFunction: differenceFunction, sampleRate: Float(buffer.format.sampleRate), maxPitch: maxPitch)
    
    
    // Step 4: Determine the Absolute Threshold
    // Apply an absolute threshold to find the first dip below the threshold in the cumulative mean normalized difference function.
    // The dip indicates the fundamental period of the signal.
    guard let fundamentalPeriod = findFundamentalPeriod(cmndf: cmndf) else {
        return nil
    }
    
    // Step 5: Parabolic Interpolation
    // Apply parabolic interpolation around the estimated fundamental period for more accuracy in pitch detection.
    let refinedPeriod = parabolicInterpolation(cmndf: cmndf, tauEstimate: fundamentalPeriod)
    
    
    // Step 6: Estimate the Pitch
    // Convert the fundamental period into a frequency value to get the pitch.
    // Handle cases where no pitch is detected (e.g., return a specific value or an error).
    if let pitch = estimatePitch(fundamentalPeriod: Int(refinedPeriod), sampleRate: Float(buffer.format.sampleRate)) {
        return pitch
    }
    
    return nil
}


private func convertBufferToFloatArray(buffer: AVAudioPCMBuffer) -> [Float] {
    guard let floatChannelData = buffer.floatChannelData else {
        return []
    }
    
    let frameLength = Int(buffer.frameLength)
    
    let channelData = floatChannelData[0]
    
    var audioSamples = [Float](repeating: 0, count: frameLength)
    
    for i in 0..<frameLength {
        audioSamples[i] = channelData[i]
    }
    
    return audioSamples
}


private func calculateDifferenceFunction(audioSamples: [Float], sampleRate: Float, minPitch: Float, maxPitch: Float) -> [Float] {
    let tauMin = Int(sampleRate / maxPitch)
    let tauMax = Int(sampleRate / minPitch)
    var difference = [Float](repeating: 0.0, count: tauMax)
    
    for tau in tauMin..<tauMax {
        var sum: Float = 0.0
        var squaredDifferences = [Float](repeating: 0.0, count: audioSamples.count - tau)
        
        audioSamples.withUnsafeBufferPointer { audioSamplesPtr in
            let basePtr = audioSamplesPtr.baseAddress!
            let shiftedPtr = basePtr.advanced(by: tau)
            
            vDSP_vsub(basePtr, 1, shiftedPtr, 1, &squaredDifferences, 1, vDSP_Length(audioSamples.count - tau))
        }
        
        vDSP_svesq(squaredDifferences, 1, &sum, vDSP_Length(squaredDifferences.count))
        difference[tau] = sum
    }
    
    return difference
}


private func calculateCMNDF(differenceFunction: [Float], sampleRate: Float, maxPitch: Float) -> [Float] {
    let tauMin = Int(sampleRate / maxPitch) // Calculate tauMin based on the minimum frequency of interest, // todo parameter
    let length = differenceFunction.count
    var cmndf = [Float](repeating: 1.0, count: length) // Initialize with 1.0
    
    var cumulativeSum: Float = 0.0
    
    for tau in tauMin..<length {
        cumulativeSum += differenceFunction[tau]
        if cumulativeSum == 0.0 {
            cmndf[tau] = 1.0
        } else {
            cmndf[tau] = differenceFunction[tau] * Float(tau) / cumulativeSum
        }
    }
    
    // For tau values less than tauMin, set CMNDF to a default high value
    for tau in 0..<tauMin {
        cmndf[tau] = 5.0
    }
    
    return cmndf
}


private func findFundamentalPeriod(cmndf: [Float]) -> Int? {
    let thresholdFactor: Float = 1.1 // Example factor to set threshold above the minimum value
    let minValue = cmndf.min() ?? 1.0
    let offset: Float = 0.001 // to keep the threshhold from being zero in uniform signal cases
    let dynamicThreshold = minValue * thresholdFactor + offset
    
    for (index, value) in cmndf.enumerated() {
        if index > 0 && value < dynamicThreshold {
            return index
        }
    }
    return nil
}

private func parabolicInterpolation(cmndf: [Float], tauEstimate: Int) -> Float {
    let betterTau: Float
    let x0: Int
    let x2: Int
    
    if tauEstimate < 1 {
        x0 = tauEstimate
    } else {
        x0 = tauEstimate - 1
    }
    
    if tauEstimate + 1 < cmndf.count {
        x2 = tauEstimate + 1
    } else {
        x2 = tauEstimate
    }
    
    if x0 == tauEstimate {
        if cmndf[tauEstimate] <= cmndf[x2] {
            betterTau = Float(tauEstimate)
        } else {
            betterTau = Float(x2)
        }
    } else if x2 == tauEstimate {
        if cmndf[tauEstimate] <= cmndf[x0] {
            betterTau = Float(tauEstimate)
        } else {
            betterTau = Float(x0)
        }
    } else {
        let s0 = cmndf[x0]
        let s1 = cmndf[tauEstimate]
        let s2 = cmndf[x2]
        betterTau = Float(tauEstimate) + (s2 - s0) / (2 * (2 * s1 - s2 - s0))
    }
    
    return betterTau
}



private func estimatePitch(fundamentalPeriod: Int, sampleRate: Float) -> Float? {
    if fundamentalPeriod > 0 {
        return sampleRate / Float(fundamentalPeriod)
    } else {
        return nil     }
}
