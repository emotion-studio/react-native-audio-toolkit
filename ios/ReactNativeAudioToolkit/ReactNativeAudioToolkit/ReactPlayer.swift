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
    var observer: NSKeyValueObservation?
    
    override init() {
        super.init()
        self.setupObserver()
    }
    
    override init(url: URL) {
        super.init(url: url)
        self.setupObserver()
    }
    
    override init(playerItem: AVPlayerItem?) {
        super.init(playerItem: playerItem)
        self.setupObserver()
    }
    
    private func setupObserver() {
        self.observer = self.observe(\.rate, options: [.old, .new]) { _, change in
            guard let oldRate = change.oldValue, let newRate = change.newValue else { return }
            if oldRate == 0.0 && newRate > 0.0 {
                self.activateAudioSession()
            }
            else if oldRate > 0.0 && newRate == 0.0 {
                self.deactivateAudioSession()
            }
        }
    }
    
    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            print("[AudioSession] - Activated audio session.")
        } catch {
            print("[AudioSession] - Failed to activate audio session: \(error)")
        }
    }
    
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print("[AudioSession] - Deactivated audio session.")
        } catch {
            print("[AudioSession] - Failed to deactivate audio session: \(error)")
        }
    }
}
