//
//  ReactPlayer.swift
//  ReactNativeAudioToolkit
//
//  Created by Edouard Goossens on 03/08/2020.
//  Copyright © 2020 React Native Community. All rights reserved.
//

import AVFoundation

class ReactPlayer: AVPlayer {
    var looping: Bool
    var autoDestroy: Bool
    var speed: Float
    
    init(withUrl url: URL) {
        self.autoDestroy = true
        self.looping = false
        self.speed = 1.0
        super.init(url: url)
    }
    
    init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
    }
}
