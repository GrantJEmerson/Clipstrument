// Created by Grant Emerson on 5/8/20.

import AVFoundation

public class CustomSampler: AVAudioUnitSampler {
    
    // MARK: Properties
    
    public var currentNote: UInt8?
    public var isPlaying: Bool { currentNote != nil }
    
    // MARK: Overriden Methods
    
    public override func startNote(_ note: UInt8, withVelocity velocity: UInt8 = 127, onChannel channel: UInt8 = 0) {
        super.startNote(note, withVelocity: velocity, onChannel: channel)
        currentNote = note
    }
    
    public override func stopNote(_ note: UInt8, onChannel channel: UInt8 = 0) {
        super.stopNote(note, onChannel: channel)
        currentNote = nil
    }
}
