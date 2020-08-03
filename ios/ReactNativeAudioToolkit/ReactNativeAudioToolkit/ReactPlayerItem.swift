//
//  ReactPlayerItem.swift
//  ReactNativeAudioToolkit
//
//  Created by Edouard Goossens on 03/08/2020.
//  Copyright © 2020 React Native Community. All rights reserved.
//

import AVFoundation

class ReactPlayerItem : AVPlayerItem {
    var reactPlayerId: Int? = nil
    
    static func playerItemWithAsset(asset: AVAsset) -> ReactPlayerItem {
        return self.init(asset: asset)
    }
}
