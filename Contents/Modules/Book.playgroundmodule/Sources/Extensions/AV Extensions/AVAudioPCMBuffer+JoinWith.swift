// Created by Grant Emerson on 5/9/20.

import AVFoundation

public extension AVAudioPCMBuffer {
    func joinedWith(_ buffer: AVAudioPCMBuffer,
                           offset: AVAudioFrameCount = 0,
                           frames: AVAudioFrameCount = 0) -> AVAudioPCMBuffer? {
        guard format == buffer.format else {
            print("Audio buffers could not be joined because their formats don't match.")
            return nil
        }
        
        let initialFrameCount = Int(frameLength)
        let framesToCopy = (frames == 0 ? Int(buffer.frameLength) : Int(frames)) - Int(offset)
        
        guard framesToCopy > 0 else {
            print("Audio buffers could not be joined because there were no frames to copy.")
            return nil
        }
        
        guard let resultBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: buffer.frameCapacity + frameCapacity) else {
            print("Could not create result audio buffer for joining buffers.")
            return nil
        }
        
        let bytesPerFrame = Int(format.streamDescription.pointee.mBytesPerFrame)
        
        if let source1 = floatChannelData,
            let source2 = buffer.floatChannelData,
            let destination = resultBuffer.floatChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(destination[channel], source1[channel], bytesPerFrame * Int(initialFrameCount))
                memcpy(destination[channel] + Int(initialFrameCount), source2[channel] + Int(offset), Int(framesToCopy) * bytesPerFrame)
            }
        } else if let source1 = int16ChannelData,
            let source2 = buffer.int16ChannelData,
            let destination = resultBuffer.int16ChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(destination[channel], source1[channel], bytesPerFrame * Int(initialFrameCount))
                memcpy(destination[channel] + Int(initialFrameCount), source2[channel] + Int(offset), Int(framesToCopy) * bytesPerFrame)
            }
        } else if let source1 = int32ChannelData,
            let source2 = buffer.int32ChannelData,
            let destination = resultBuffer.int32ChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(destination[channel], source1[channel], bytesPerFrame * Int(initialFrameCount))
                memcpy(destination[channel] + Int(initialFrameCount), source2[channel] + Int(offset), Int(framesToCopy) * bytesPerFrame)
            }
        } else {
            return nil
        }
        
        resultBuffer.frameLength = AVAudioFrameCount(initialFrameCount + framesToCopy)
        
        return resultBuffer
    }
}
