//
//  AudioPlayer.swift
//  ReactNativeAudioToolkit
//
//  Created by Edouard Goossens on 03/08/2020.
//  Copyright © 2020 React Native Community. All rights reserved.
//

import AVFoundation

@objc(AudioPlayer)
class AudioPlayer : NSObject {
    private var observer: NSKeyValueObservation?
    private var playerPool = [Int: AVPlayer]()
    @objc var bridge: RCTBridge!
    
    override init() {
        super.init()
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(handleRouteChange(notification:)),
                         name: AVAudioSession.routeChangeNotification,
                         object: nil)
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(handleInterruption(notification:)),
                         name: AVAudioSession.interruptionNotification,
                         object: nil)
        self.configureAudioSession()
    }
    
    @objc
    private func itemDidFinishPlaying(notification: Notification) {
        guard let item = notification.object as? ReactPlayerItem,
            let playerId = item.reactPlayerId,
            let player = self.playerPool[playerId] as? ReactPlayer else {
            print("Couldn't find playerId in notification object")
                return
        }
        player.pause()
        
        if player.autoDestroy {
            self.destroyPlayer(withId: playerId)
        } else {
            self.seek(playerId, withPosition: 0, withCallback: {_ in return})
        }
        
        if player.looping {
            self.bridge
                .eventDispatcher()
                .sendAppEvent(withName: "RCTAudioPlayerEvent:\(playerId)",body: [
                    "event": "looped",
                    "data": nil,
                ])
            player.play()
            //player.rate = player.speed
        } else {
            self.bridge
            .eventDispatcher()
            .sendAppEvent(withName: "RCTAudioPlayerEvent:\(playerId)",body: [
                "event": "ended",
                "data": nil,
            ])
        }
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            let categoryOptions: AVAudioSession.CategoryOptions = [
                .duckOthers,
                .defaultToSpeaker,
                .allowBluetooth,
            ]
            try audioSession.setCategory(.playAndRecord, options: categoryOptions)
        } catch {
            print("[AudioSession] - Failed to set audio session category: \(error)")
        }
    }
    
    private func listRouteChannels(route: AVAudioSessionRouteDescription) {
        print("[AudioSession] - Available outputs:")
        for output in route.outputs {
            print(output)
        }
        print("[AudioSession] - Available inputs:")
        for input in route.inputs {
            print(input)
        }
    }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
        }
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        
        // Switch over the route change reason.
        switch reason {

        case .newDeviceAvailable: // New device found.
            //let session = AVAudioSession.sharedInstance()
            //headphonesConnected = hasHeadphones(in: session.currentRoute)
            print("[AudioSession] - Route change. New device available.")
            break
        case .oldDeviceUnavailable: // Old device removed.
            print("[AudioSession] - Route change. Old device unavailable.")
            break
        default: ()
        }
        self.listRouteChannels(route: currentRoute)
        /* do {
            if !hasHeadphones(in: currentRoute) {
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                print("[AudioSession] - Overrode output port to speaker")
            } else {
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                print("[AudioSession] - Overrode output port to none")
            }
        } catch {
            print("[AudioSession] - Failed to override output port")
        } */
    }
    
    func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        // Filter the outputs to only those with a port type of headphones.
        return !routeDescription.outputs.filter({$0.portType == .headphones}).isEmpty
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        // Switch over the interruption type.
        switch type {

        case .began:
            // An interruption began. Update the UI as needed.
            print("[AudioSession] - Interruption began.")
            break;
        case .ended:
           // An interruption ended. Resume playback, if appropriate.
            print("[AudioSession] - Interruption ended.")
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption ended. Playback should resume.
                print("[AudioSession] - Playback should resume.")
            } else {
                // Interruption ended. Playback should not resume.
                print("[AudioSession] - Playback should not resume.")
            }

        default: ()
        }
    }
    
    private func findURL(forPath path: String) -> URL? {
        guard let possibleURL = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(path) else {
                print("Error in findURL: Path not found")
                return nil
        }
        
        if !FileManager.default.fileExists(atPath: possibleURL.absoluteString) {
            let fileWithoutExtension = possibleURL.deletingPathExtension();
            let ext = possibleURL.pathExtension;
            if let urlString = Bundle.main.path(forResource: fileWithoutExtension.absoluteString, ofType: ext) {
                return URL(fileURLWithPath: urlString)
            } else {
                let mainBundle = Bundle.main.bundlePath.appending("/\(path)")
                if FileManager.default.fileExists(atPath: mainBundle) {
                    return URL(fileURLWithPath: mainBundle)
                }
            }
        }
        
        return URL(fileURLWithPath: path);
    }
    
    private func destroyPlayer(withId playerId: Int) {
        if let player = self.playerPool[playerId] as? ReactPlayer {
            player.pause()
            self.playerPool.removeValue(forKey: playerId)
        }
        return
    }
    
    @objc(test)
    func test() {
        print("Hello from Swift!")
    }

    @objc(prepare:withPath:withOptions:withCallback:)
    func prepare(_ playerId: Int,
                 withPath path: String,
                 withOptions options: NSDictionary,
                 withCallback callback: RCTResponseSenderBlock) {
        
        if path.count == 0 {
            callback(Helpers.errObj(withCode: "invalidpath", withMessage: "Provided path was empty"))
            return
        }
        
        guard let url = findURL(forPath: path) else {
            callback(Helpers.errObj(withCode: "invalidpath", withMessage: "No file found at path"))
            return
        }
        
        let asset = AVURLAsset(url: url)
        let item = ReactPlayerItem.playerItemWithAsset(asset: asset)
        item.reactPlayerId = playerId
        
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(itemDidFinishPlaying(notification:)),
                         name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                         object: item)
        
        let player = ReactPlayer(playerItem: item)
        if let autoDestroy = options["autoDestroy"] as? Bool {
            player.autoDestroy = autoDestroy
        }
        self.playerPool[playerId] = player
        
        while player.status == .unknown {
            Thread.sleep(forTimeInterval: 0.01)
        }
        
        if player.status == .failed {
            print("[AudioPlayer] - Could not initialize player: \(player.error.debugDescription)")
            callback(Helpers.errObj(withCode: "preparefail",
                                    withMessage: "Could not initialize player: \(player.error.debugDescription)"))
        }
        
        guard let currentItem = player.currentItem else {
            print("[AudioPlayer] - Could not initialize player: current item is nil.")
            callback(Helpers.errObj(withCode: "preparefail",
                                    withMessage: "Could not initialize player: current item is nil"))
            return
        }
        
        while currentItem.status == .unknown {
            Thread.sleep(forTimeInterval: 0.01)
        }
        
        if currentItem.status == .failed {
            print("[AudioPlayer] - Could not initialize player: \(player.error.debugDescription)")
            callback(Helpers.errObj(withCode: "preparefail",
                                    withMessage: "Could not initialize player: \(player.error.debugDescription)"))
            return
        }
        
        while currentItem.loadedTimeRanges.first == nil {
            Thread.sleep(forTimeInterval: 0.01)
        }
        
        if #available(iOS 10.0, *) {
            currentItem.preferredForwardBufferDuration = 500
            player.automaticallyWaitsToMinimizeStalling = false
        }
        
        var loadedDuration = 0.0
        let totalDurationSeconds = currentItem.duration.seconds
        while loadedDuration < 10.0 && loadedDuration < totalDurationSeconds {
            loadedDuration = currentItem.loadedTimeRanges.first?.timeRangeValue.duration.seconds ?? 0.0
            Thread.sleep(forTimeInterval: 0.01)
        }
        
        if currentItem.status == .readyToPlay {
            if #available(iOS 10.0, *) {
                player.automaticallyWaitsToMinimizeStalling = false
            }
            callback([NSNull()])
        } else {
            if player.autoDestroy {
                self.destroyPlayer(withId: playerId)
            }
            print("[AudioPlayer] - Preparing player failed.")
            callback(Helpers.errObj(withCode: "preparefail", withMessage: "Preparing player failed"))
        }
    }
    
    @objc
    func destroy(_ playerId: Int, withCallback callback: RCTResponseSenderBlock) {
        self.destroyPlayer(withId: playerId)
        callback([NSNull()])
    }
    
    @objc
    func seek(_ playerId: Int,
              withPosition position: Int,
              withCallback callback: @escaping RCTResponseSenderBlock) {
        if let player = self.playerPool[playerId] as? ReactPlayer,
            let currentItem = player.currentItem {
            player.cancelPendingPrerolls()
            if position >= 0 {
                print(position)
                if (position == 0) {
                    currentItem.seek(to: CMTime.zero, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in
                        callback([NSNull(), [
                            "duration": currentItem.asset.duration.seconds * 1000,
                            "position": player.currentTime().seconds * 1000,
                        ]])
                    }
                } else {
                    let time = CMTime(seconds: Double(position)/1000.0, preferredTimescale: 60000)
                    currentItem.seek(to: time) { _ in
                        callback([NSNull(), [
                            "duration": currentItem.asset.duration.seconds * 1000,
                            "position": player.currentTime().seconds * 1000,
                        ]])
                    }
                }
            }
        } else {
            callback(Helpers.errObj(withCode: "notfound", withMessage: "playerId \(playerId) not found."))
            return
        }
    }
    
    
    @objc
    func set(_ playerId: Int, withOptions options: [String: Any], withCallback callback: RCTResponseSenderBlock) {
        guard let player = self.playerPool[playerId] as? ReactPlayer else {
            callback(Helpers.errObj(withCode: "notfound",
                                    withMessage: "playerId \(playerId) not found."))
            return
        }
        
        if let volume = options["volume"] as? Float {
            player.volume = volume
        }
        
        if let looping = options["looping"] as? Bool {
            player.looping = looping
        }
        
        if let speed = options["speed"] as? Float {
            player.speed = speed
            if player.rate != 0.0 {
                player.rate = player.speed
            }
        }
        
        callback([NSNull()])
    }
    
    @objc
    func stop(_ playerId: Int, withCallback callback: RCTResponseSenderBlock) {
        guard let player = self.playerPool[playerId] as? ReactPlayer,
            let currentItem = player.currentItem else {
            callback(Helpers.errObj(withCode: "notfound",
                                    withMessage: "playerId \(playerId) not found."))
            return
        }
        player.pause()
        if player.autoDestroy {
            self.destroyPlayer(withId: playerId)
        } else {
            player.currentItem?.seek(to: CMTime.zero)
        }
        
        callback([NSNull(), [
            "duration": currentItem.asset.duration.seconds * 1000,
            "position": player.currentTime().seconds * 1000,
        ]])
    }
    
    @objc
    func play(_ playerId: Int, withCallback callback: RCTResponseSenderBlock) {
        guard let player = self.playerPool[playerId] as? ReactPlayer,
            let currentItem = player.currentItem else {
            callback(Helpers.errObj(withCode: "notfound",
                                    withMessage: "playerId \(playerId) not found."))
            return
        }
        player.play()
        //player.rate = player.speed
        
        callback([NSNull(), [
            "duration": currentItem.asset.duration.seconds * 1000,
            "position": player.currentTime().seconds * 1000,
        ]])
    }
    
    @objc
    func pause(_ playerId: Int, withCallback callback: RCTResponseSenderBlock) {
        guard let player = self.playerPool[playerId] as? ReactPlayer,
            let currentItem = player.currentItem else {
            callback(Helpers.errObj(withCode: "notfound",
                                    withMessage: "playerId \(playerId) not found."))
            return
        }
        player.pause()
        callback([NSNull(), [
            "duration": currentItem.asset.duration.seconds * 1000,
            "position": player.currentTime().seconds * 1000,
        ]])
    }
    
    @objc
    func resume(_ playerId: Int, withCallback callback: RCTResponseSenderBlock) {
        guard let player = self.playerPool[playerId] as? ReactPlayer,
            let currentItem = player.currentItem else {
            callback(Helpers.errObj(withCode: "notfound",
                                    withMessage: "playerId \(playerId) not found."))
            return
        }
        player.play()
        player.rate = player.speed
        
        callback([NSNull(), [
            "duration": currentItem.asset.duration.seconds * 1000,
            "position": player.currentTime().seconds * 1000,
        ]])
    }
    
    @objc
    func getCurrentTime(_ playerId: Int, withCallback callback: RCTResponseSenderBlock) {
        guard let player = self.playerPool[playerId] as? ReactPlayer,
            let currentItem = player.currentItem else {
            callback(Helpers.errObj(withCode: "notfound",
                                    withMessage: "playerId \(playerId) not found."))
            return
        }
        
        callback([NSNull(), [
            "duration": currentItem.asset.duration.seconds * 1000,
            "position": player.currentTime().seconds * 1000,
        ]])
    }
}
