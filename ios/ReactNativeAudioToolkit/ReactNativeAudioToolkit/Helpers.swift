//
//  Helpers.swift
//  ReactNativeAudioToolkit
//
//  Created by Edouard Goossens on 03/08/2020.
//  Copyright © 2020 React Native Community. All rights reserved.
//

import AVFoundation

struct Helpers {
    static func errObj(withCode code: String, withMessage message: String) -> [[String: Any]] {
        return [[
            "err": code,
            "message": message,
            "stackTrace": Thread.callStackSymbols,
        ]]
    }
    
    static func recorderSettings(fromOptions options: [String: Any]) -> [String: Any] {
        return [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: options["sampleRate"] ?? 44100,
            AVNumberOfChannelsKey: options["channels"] ?? 2,
            AVEncoderBitRateKey: options["bitRate"] ?? 128000,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
        ]
    }
}
