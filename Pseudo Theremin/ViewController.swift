//
//  ViewController.swift
//  Pseudo Theremin
//
//  Created by KUMATA Tomokatsu on 2016/11/19.
//  Copyright © 2016 KUMATA Tomokatsu. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    // エンジンの生成
    let audioEngine = AVAudioEngine()
    // ソースノードの生成
    let player = AVAudioPlayerNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        FMSynthesizer.sharedSynth().play(440.0, modulatorAmplitude: 0.8)
//        _ = SinePlayer()
        playSineWave()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func playSineWave() {
        // プレイヤーノードからオーディオフォーマットを取得
        let audioFormat = player.outputFormat(forBus: 0)
        // サンプリング周波数: 44.1K Hz
        let sampleRate = Float(audioFormat.sampleRate)
        //
        let mixer = audioEngine.mainMixerNode
        // 3秒間鳴らすフレームの長さ
        let length = 3.0 * sampleRate
        // PCMバッファーを生成
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity:UInt32(length))
        // frameLength を設定することで mDataByteSize が更新される
        buffer.frameLength = UInt32(length)
        // オーディオのチャンネル数
        let channels = Int(audioFormat.channelCount)
        for ch in (0..<channels) {
            let samples = buffer.floatChannelData?[ch]
            for n in 0..<Int(buffer.frameLength) {
                samples?[n] = sinf(Float(2.0 * M_PI) * 440.0 * Float(n) / sampleRate)
            }
        }
        
        // オーディオエンジンにプレイヤーをアタッチ
        audioEngine.attach(player)
        // プレイヤーノードとミキサーノードを接続
        audioEngine.connect(player, to: mixer, format: audioFormat)
        // 再生の開始を設定
        player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
//        player.scheduleBuffer(buffer) {
//            print("Play completed")
//        }
        
        do {
            // エンジンを開始
            try audioEngine.start()
            // 再生
            player.play()
        } catch let error {
            print(error)
        }
    }


}
