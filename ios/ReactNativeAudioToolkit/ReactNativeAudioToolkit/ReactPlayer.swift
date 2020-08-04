//
//  ReactPlayer.swift
//  ReactNativeAudioToolkit
//
//  Created by Edouard Goossens on 03/08/2020.
//  Copyright © 2020 React Native Community. All rights reserved.
//

import AVFoundation

class ReactPlayer: AVPlayer {
    var looping = false
    var autoDestroy = true
    var speed = Float(1.0)
    
    init(withUrl url: URL) {
        super.init(url: url)
    }
    
    override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
    }
}
