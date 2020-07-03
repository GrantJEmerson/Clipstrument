// Created by Grant Emerson on 5/8/20.

import AVFoundation

public class Sampler {
    
    public enum AudioEffectValue {
        case reverb(wetDryMix: Float)
        case delay(wetDryMix: Float)
        case distortion(wetDryMix: Float)
        case lowPassFilter(frequency: Float)
    }
    
    // MARK: Properties
    
    public var selectedFilm: Film = .gulliversTravels {
        didSet { loadSamplesForFilm(selectedFilm) }
    }
    
    public private(set) var audioFileIsEmpty = true
    
    public private(set) var selectedSamples: [SampleType: [UInt8]] = {
        var selectedSamples = [SampleType: [UInt8]]()
        for sampleType in SampleType.all {
            selectedSamples[sampleType] = []
        }
        return selectedSamples
    }()
    
    private var pitchBendValues = [UInt16](repeating: 0, count: 4 * SampleType.all.count)
    
    private let baseMIDINote: UInt8 = 69
    
    public private(set) var isRecording = false
    public private(set) var isPlaying = false
    
    private lazy var recordingAudioFile: AVAudioFile = createNewAudioFile()
    private var playbackBuffer: AVAudioPCMBuffer?
    
    private var audioEngine: AVAudioEngine!
    private var audioPlayerNode: AVAudioPlayerNode!
    private var audioUnitSamplerNodes = [SampleType: CustomSampler]()
    private var samplerMixerNode: AVAudioMixerNode!
    
    private var reverbEffectNode: AVAudioUnitReverb!
    private var delayEffectNode: AVAudioUnitDelay!
    private var distortionEffectNode: AVAudioUnitDistortion!
    private var lowPassFilterEffectNode: AVAudioUnitEQ!

    public init() {
        setUpAudioEngine()
        setUpAudioPlayer()
        setUpAudioSession()
        setUpSamplers()
        setUpAudioEffects()
        loadSamplesForFilm(selectedFilm)
        startEngine()
    }
    
    // MARK: Private Functions
    
    private func setUpAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord)
        } catch {
            preconditionFailure("Couldn't set category on audio session. Error: \(error.localizedDescription)")
        }
        
        do {
            try audioSession.setActive(true)
        } catch {
            preconditionFailure("Couldn't activate audio session. Error: \(error.localizedDescription)")
        }
    }
    
    private func setUpAudioEngine() {
        audioEngine = AVAudioEngine()
    }
    
    private func setUpSamplers() {
        samplerMixerNode = AVAudioMixerNode()
        audioEngine.attach(samplerMixerNode)
        
        for sampleType in SampleType.all {
            let audioUnitSampler = CustomSampler()
            audioEngine.attach(audioUnitSampler)
            audioEngine.connect(audioUnitSampler,
                                to: samplerMixerNode,
                                format: audioUnitSampler.outputFormat(forBus: 0))
            audioUnitSamplerNodes[sampleType] = audioUnitSampler
        }
    }
    
    private func setUpAudioEffects() {
        reverbEffectNode = AVAudioUnitReverb()
        reverbEffectNode.loadFactoryPreset(.largeHall)
        reverbEffectNode.wetDryMix = 0
        
        delayEffectNode = AVAudioUnitDelay()
        delayEffectNode.delayTime = 0.15
        delayEffectNode.wetDryMix = 0
        
        distortionEffectNode = AVAudioUnitDistortion()
        distortionEffectNode.loadFactoryPreset(.multiDistortedCubed)
        distortionEffectNode.wetDryMix = 0
        
        lowPassFilterEffectNode = AVAudioUnitEQ(numberOfBands: 1)
        lowPassFilterEffectNode.bands[0].filterType = .lowPass
        lowPassFilterEffectNode.bands[0].bypass = true
        lowPassFilterEffectNode.bands[0].frequency = 5000
        
        audioEngine.attach(distortionEffectNode)
        audioEngine.attach(delayEffectNode)
        audioEngine.attach(reverbEffectNode)
        audioEngine.attach(lowPassFilterEffectNode)
        
        audioEngine.connect(samplerMixerNode,
                            to: distortionEffectNode,
                            format: samplerMixerNode.outputFormat(forBus: 0))
        audioEngine.connect(distortionEffectNode,
                            to: delayEffectNode,
                            format: distortionEffectNode.outputFormat(forBus: 0))
        audioEngine.connect(delayEffectNode,
                            to: reverbEffectNode,
                            format: delayEffectNode.outputFormat(forBus: 0))
        audioEngine.connect(reverbEffectNode,
                            to: lowPassFilterEffectNode,
                            format: reverbEffectNode.outputFormat(forBus: 0))
        audioEngine.connect(lowPassFilterEffectNode,
                            to: audioEngine.mainMixerNode,
                            format: lowPassFilterEffectNode.outputFormat(forBus: 0))
    }
    
    private func setUpAudioPlayer() {
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode,
                            to: audioEngine.mainMixerNode,
                            format: audioPlayerNode.outputFormat(forBus: 0))
    }
    
    private func loadSamplesForFilm(_ film: Film) {
        guard let soundfountDirectoryURL = Bundle.main.url(forResource: "Soundfonts", withExtension: nil) else {
            preconditionFailure("Could not load soundfont directory.")
        }
        
        let preset = film.rawValue
        
        for sampleType in SampleType.all {
            guard let audioUnitSampler = audioUnitSamplerNodes[sampleType] else {
                preconditionFailure("There is no sampler initialized for the sample type: \(sampleType.name)")
            }
            
            let soundfontURL = soundfountDirectoryURL.appendingPathComponent("\(sampleType.name).sf2")
            
            do {
                try audioUnitSampler.loadSoundBankInstrument(at: soundfontURL,
                                                             program: UInt8(preset),
                                                             bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                                             bankLSB: UInt8(kAUSampler_DefaultBankLSB))
                audioUnitSampler.sendProgramChange(UInt8(preset),
                                                   bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                                   bankLSB: UInt8(kAUSampler_DefaultBankLSB),
                                                   onChannel: 0)
            } catch {
                preconditionFailure("Could not load soundfont at: \(soundfontURL.absoluteURL). Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func startEngine() {
        do {
            try audioEngine.start()
        } catch {
            preconditionFailure("Couldn't start the engine. Error: \(error.localizedDescription)")
        }
    }
    
    private func createNewAudioFile() -> AVAudioFile {
        let url = URL.generateTemporaryURLWithExtension("caf")
        let settings = audioEngine.mainMixerNode.outputFormat(forBus: 0).settings
        do {
            return try AVAudioFile(forWriting: url, settings: settings)
        } catch {
            preconditionFailure("Unable to create audio file.")
        }
    }
    
    private func clearRecordingFile() {
        do {
            try FileManager.default.removeItem(at: recordingAudioFile.url)
        } catch {
            preconditionFailure("Could not remove file at url: \(recordingAudioFile.url.absoluteString). Error: \(error.localizedDescription).")
        }
    }
    
    // MARK: Public Methods
    
    public func play(_ sampleType: SampleType, with index: Int) {
        guard let audioUnitSampler = audioUnitSamplerNodes[sampleType] else { return }
        
        let note = baseMIDINote + UInt8(index)
        
        if let currentlyPlayingNote = selectedSamples[sampleType]?.last {
            audioUnitSampler.stopNote(currentlyPlayingNote)
        }
        
        selectedSamples[sampleType]?.append(note)
        audioUnitSampler.startNote(note)
    }
    
    public func stop(_ sampleType: SampleType, with index: Int) {
        guard let audioUnitSampler = audioUnitSamplerNodes[sampleType] else { return }
        
        let note = baseMIDINote + UInt8(index)
        selectedSamples[sampleType]?.removeAll(where: { $0 == note })
        pitchBendValues[sampleType.rawValue * 4 + index] = 0
        
        if note == audioUnitSampler.currentNote,
            let mostRecentNote = selectedSamples[sampleType]?.last {
            let pitchBendValue = pitchBendValues[sampleType.rawValue * 4 + Int(mostRecentNote - baseMIDINote)]
            audioUnitSampler.sendPitchBend(pitchBendValue, onChannel: 0)
            audioUnitSampler.startNote(mostRecentNote)
        }
        
        audioUnitSampler.stopNote(note)
    }
    
    public func setPitchBendTo(_ pitchBend: Float, for sampleType: SampleType, at index: Int) {
        guard let audioUnitSampler = audioUnitSamplerNodes[sampleType],
            let selectedNotes = selectedSamples[sampleType],
            let currentNote = selectedNotes.last,
            currentNote - baseMIDINote == index else { return }
        
        var limitedPitchBend = pitchBend
        
        if limitedPitchBend > 1 {
            limitedPitchBend = 1
        } else if limitedPitchBend < -1 {
            limitedPitchBend = -1
        }
        
        let intPitchBend = UInt16(8192 + limitedPitchBend * 8191)
        audioUnitSampler.sendPitchBend(intPitchBend, onChannel: 0)
        pitchBendValues[sampleType.rawValue * 4 + index] = intPitchBend
    }
    
    public func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        
        let mixer = audioEngine.mainMixerNode
        let format = mixer.outputFormat(forBus: 0)
        
        mixer.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            guard let self = self else { return }
            
            do {
                try self.recordingAudioFile.write(from: buffer)
            } catch {
                assertionFailure("Failed to write buffer.")
            }
        }
    }
    
    public func stopRecording() {
        guard isRecording else { return }
        isRecording = false
        audioFileIsEmpty = false
        
        let mixer = audioEngine.mainMixerNode
        mixer.removeTap(onBus: 0)
        
        do {
            let readRecordingAudioFile = try AVAudioFile(forReading: recordingAudioFile.url, commonFormat: recordingAudioFile.processingFormat.commonFormat, interleaved: recordingAudioFile.processingFormat.isInterleaved)
            
            let newBuffer = AVAudioPCMBuffer(pcmFormat: recordingAudioFile.processingFormat, frameCapacity: AVAudioFrameCount(recordingAudioFile.length))!
            try readRecordingAudioFile.read(into: newBuffer)
            
            if playbackBuffer != nil,
                let combinedBuffer = newBuffer.joinedWith(playbackBuffer!, offset: newBuffer.frameLength) {
                playbackBuffer = combinedBuffer
            } else {
                playbackBuffer = newBuffer
            }
        } catch {
            preconditionFailure("Could not fill buffer with audio. Error: \(error.localizedDescription).")
        }
        
        clearRecordingFile()
        recordingAudioFile = createNewAudioFile()
    }
    
    public func startAudioPlayback() {
        guard let buffer = playbackBuffer else { return }
        audioPlayerNode.scheduleBuffer(buffer, at: nil, options: [.interrupts, .loops])
        audioPlayerNode.play()
        isPlaying = true
    }
    
    public func stopAudioPlayback() {
        guard isPlaying else { return }
        audioPlayerNode.stop()
        isPlaying = false
    }
    
    public func clearAudioRecording() {
        playbackBuffer = nil
        audioFileIsEmpty = true
    }
    
    public func setAudioEffectValue(_ audioEffectValue: AudioEffectValue) {
        switch audioEffectValue {
        case .reverb(let wetDryMix):
            reverbEffectNode.wetDryMix = wetDryMix
        case .delay(let wetDryMix):
            delayEffectNode.wetDryMix = wetDryMix
        case .distortion(let wetDryMix):
            distortionEffectNode.wetDryMix = wetDryMix
        case .lowPassFilter(let frequency):
            lowPassFilterEffectNode.bands[0].frequency = frequency == 0 ? 1 : frequency
            lowPassFilterEffectNode.bands[0].bypass = frequency >= 5000
        }
    }
}
