//
//  File2.swift
//  Pseudo Theremin
//
//  Created by KUMATA Tomokatsu on 2016/11/19.
//  Copyright © 2016 KUMATA Tomokatsu. All rights reserved.
//

import Foundation
import AVFoundation

class SinePlayer {
    // store persistent objects
    var ae:AVAudioEngine
    var player:AVAudioPlayerNode
    var mixer:AVAudioMixerNode
    var buffer:AVAudioPCMBuffer
    
    init() {
        // initialize objects
        ae = AVAudioEngine()
        player = AVAudioPlayerNode()
        mixer = ae.mainMixerNode;
        buffer = AVAudioPCMBuffer(pcmFormat: player.outputFormat(forBus: 0), frameCapacity: 100)
        buffer.frameLength = 100
        
        // generate sine wave
        let sr:Float = Float(mixer.outputFormat(forBus: 0).sampleRate)
        let n_channels = mixer.outputFormat(forBus: 0).channelCount
        
        for var i in 0 ..< Int(buffer.frameLength) {
            let val = sinf(441.0*Float(i)*2*Float(M_PI)/sr)
            
            buffer.floatChannelData?.pointee[i] = val * 0.5
            print(i)
            i += Int(n_channels)
        }
        
        // setup audio engine
        ae.attach(player)
        ae.connect(player, to: mixer, format: player.outputFormat(forBus: 0))
        try! ae.start()
        
        // play player and buffer
        player.pan = 0.8
        player.play()
        player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        
    }
    
}
