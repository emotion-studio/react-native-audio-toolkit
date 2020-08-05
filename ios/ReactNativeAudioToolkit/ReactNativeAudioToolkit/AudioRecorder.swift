import AVFoundation

@objc(AudioRecorder)
class AudioRecorder : NSObject, AVAudioRecorderDelegate {
    private var recorderPool = [Int: AVAudioRecorder]()
    @objc var bridge: RCTBridge!
    private var observer: NSKeyValueObservation?

    private func keyForRecorder(recorder: AVAudioRecorder) -> Int? {
        return self.recorderPool.first(where: { $0.value == recorder })?.key
    }
    
    override init() {
        super.init()
        self.configureAudioSession()
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
    
    @objc
    func prepare(_ recorderId: Int,
                 withPath filename: String,
                 withOptions options: [String: Any],
                 withCallback callback: RCTResponseSenderBlock) -> Void {
        if filename.count == 0 {
            callback(Helpers.errObj(withCode: "invalidpath", withMessage: "Provided path was empty"))
            return
        } else if (self.recorderPool[recorderId] != nil) {
            callback(Helpers.errObj(withCode: "invalidpath", withMessage: "Recorder with that id already exists"))
            return
        }
        guard let filePath = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(filename) else {
                callback(Helpers.errObj(withCode: "invalidpath", withMessage: "Path not found"))
                return
        }
        
        do {
            let recordSettings = Helpers.recorderSettings(fromOptions: options)
            let recorder = try AVAudioRecorder(url: filePath, settings: recordSettings)
            recorder.delegate = self;
            self.recorderPool[recorderId] = recorder;
            if !recorder.prepareToRecord() {
                callback(Helpers.errObj(withCode: "preparefail", withMessage: "Failed to prepare recorder. Settings are probably wrong."))
                return
            }
            callback([NSNull(), filePath.absoluteString])
        } catch {
            let errorMessage = "Failed to initialize recorder, error: \(error)"
            callback(Helpers.errObj(withCode: "preparefail", withMessage: errorMessage))
            return
        }
    }
    
    @objc
    func record(_ recorderId: Int, withCallback callback: RCTResponseSenderBlock) {
        guard let recorder = self.recorderPool[recorderId] else {
            callback(Helpers.errObj(withCode: "notfound", withMessage: "Recorder with that id was not found"))
            return
        }
        
        if !recorder.record() {
            callback(Helpers.errObj(withCode: "startfail", withMessage: "Failed to start recorde"))
            return
        }
        self.activateAudioSession()
        
        callback([NSNull()])
    }
    
    @objc
    func stop(_ recorderId: Int, withCallback callback: RCTResponseSenderBlock) {
        guard let recorder = self.recorderPool[recorderId] else {
            callback(Helpers.errObj(withCode: "notfound", withMessage: "Recorder with that id was not found"))
            return
        }
        
        recorder.stop()
        self.deactivateAudioSession()
        callback([NSNull()])
    }
    
    @objc
    func pause(_ recorderId: Int, withCallback callback: RCTResponseSenderBlock) {
        guard let recorder = self.recorderPool[recorderId] else {
            callback(Helpers.errObj(withCode: "notfound", withMessage: "Recorder with that id was not found"))
            return
        }
        
        recorder.pause()
        callback([NSNull()])
    }
    
    @objc
    func destroy(_ recorderId: Int, withCallback callback: RCTResponseSenderBlock) {
        self.destroyRecorder(withId: recorderId)
        callback([NSNull()])
    }
    
    private func destroyRecorder(withId recorderId: Int) {
        if let recorder = self.recorderPool[recorderId] {
            recorder.stop()
            self.bridge.eventDispatcher()?.sendAppEvent(withName: "RCTAudioRecorderEvent:\(recorderId)", body: [
                "event": "ended",
                "data": nil,
            ])
        }
    }
    
    // MARK: Delegate methods
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let key = keyForRecorder(recorder: recorder) {
            self.destroyRecorder(withId: key)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let key = keyForRecorder(recorder: recorder) {
            self.destroyRecorder(withId: key)
            self.bridge.eventDispatcher()?.sendAppEvent(withName: "RCTAudioRecorderEvent:\(key)", body: [
                "event": "error",
                "data": error.debugDescription,
            ])
        }
    }
}
