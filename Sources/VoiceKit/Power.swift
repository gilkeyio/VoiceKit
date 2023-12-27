//
//  Power.swift
//
//

import Foundation
import AVFoundation
import Accelerate

public func calculateDecibelLevel(buffer: AVAudioPCMBuffer) -> Float {
    guard let floatChannelData = buffer.floatChannelData else {
        return -Float.infinity
    }

    let frameLength = Int(buffer.frameLength)
    let channelData = floatChannelData[0]
    
    var sum: Float = 0.0
    vDSP_svesq(channelData, 1, &sum, vDSP_Length(frameLength))

    let rms = sqrt(sum / Float(frameLength))
    
    let db = 20 * log10(rms)
    return db
}

