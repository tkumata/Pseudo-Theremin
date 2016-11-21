//
//  ViewController.swift
//  Pseudo Theremin
//
//  Created by KUMATA Tomokatsu on 2016/11/19.
//  Copyright © 2016 KUMATA Tomokatsu. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var hertzLabelOutlet: UILabel!
    @IBOutlet weak var volUpButtonOutlet: UIButton!
    @IBOutlet weak var volDownButtonOutlet: UIButton!
    @IBOutlet weak var brightnessLabel: UILabel!
    @IBOutlet weak var buttonBackground: UILabel!
    
    // for sine wave sound.
    var hertz: Float32 = 440.1
    let repeatPeriod: Double = 0.5
    let audioEngine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    
    var timer: Timer!
    
    // for camera.
    var input: AVCaptureDeviceInput!
    var output: AVCaptureVideoDataOutput!
    var session: AVCaptureSession!
    var camera: AVCaptureDevice!
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = .green
        
        // Hertz label attribute.
        hertzLabelOutlet.layer.borderWidth = 1.0
        hertzLabelOutlet.layer.cornerRadius = 5.0
        hertzLabelOutlet.layer.borderColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0).cgColor
        
        // Up button attribute.
        volUpButtonOutlet.layer.borderWidth = 5.0
        volUpButtonOutlet.layer.cornerRadius = 10.0
        volUpButtonOutlet.layer.borderColor = UIColor(red: 255/255, green: 192/255, blue: 192/255, alpha: 1.0).cgColor
        volUpButtonOutlet.layer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1.0).cgColor
        volUpButtonOutlet.layer.zPosition = 2
        
        // Down button attribute.
        volDownButtonOutlet.layer.borderWidth = 5.0
        volDownButtonOutlet.layer.cornerRadius = 10.0
        volDownButtonOutlet.layer.borderColor = UIColor(red: 255/255, green: 192/255, blue: 192/255, alpha: 1.0).cgColor
        volDownButtonOutlet.layer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1.0).cgColor
        volDownButtonOutlet.layer.zPosition = 2
        
        // Background attribute of up/down button.
        buttonBackground.text = ""
        buttonBackground.layer.borderWidth = 1.0
        buttonBackground.layer.cornerRadius = 10.0
        buttonBackground.layer.borderColor = UIColor(red: 42/255, green: 192/255, blue: 255/255, alpha: 1.0).cgColor
        buttonBackground.layer.backgroundColor = UIColor(red: 42/255, green: 192/255, blue: 255/255, alpha: 1.0).cgColor
        buttonBackground.layer.zPosition = 0

        // Preparing camera.
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        for caputureDevice: Any in AVCaptureDevice.devices() {
            // 前面カメラを取得
            if (caputureDevice as AnyObject).position == AVCaptureDevicePosition.front {
                camera = caputureDevice as? AVCaptureDevice
            }
        }
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        output = AVCaptureVideoDataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)]
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        output.alwaysDiscardsLateVideoFrames = true
        session.startRunning()
        
        //
        timer = Timer.scheduledTimer(timeInterval: repeatPeriod+0.2,
                                     target: self,
                                     selector: #selector(self.playSineWaveSound),
                                     userInfo: nil,
                                     repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 周波数 hertz の正弦波の音を生成して再生する。
    func playSineWaveSound() {
//        print(hertz)
        let audioFormat = player.outputFormat(forBus: 0)
        let sampleRate = Float(audioFormat.sampleRate)
        let mixer = audioEngine.mainMixerNode
        let length = Float(repeatPeriod) * sampleRate
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: UInt32(length))
        buffer.frameLength = UInt32(length)
        let channels = Int(audioFormat.channelCount)
        
        for ch in 0 ..< channels { // 左右チャンネル分を回す (重点)
            let samples = buffer.floatChannelData?[ch]
            
            for n in 0 ..< Int(buffer.frameLength) {
                samples?[n] = sinf(Float(2.0 * M_PI) * hertz * Float(n) / sampleRate)
            }
        }
        
        audioEngine.attach(player)
        audioEngine.connect(player, to: mixer, format: audioFormat)
//        player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        player.scheduleBuffer(buffer, completionHandler: soundEnded)
        
        do {
            try audioEngine.start()
//            print("start.")
            player.play()
        } catch let error {
            print(error)
        }
    }
    
    func soundEnded() {
        if audioEngine.isRunning {
//            print("stop.")
//            player.stop()
            audioEngine.disconnectNodeInput(player)
            audioEngine.detach(player)
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // カメラから輝度を取得
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        let rawMetaData = CMCopyDictionaryOfAttachments(nil, sampleBuffer, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
        let metaData = CFDictionaryCreateMutableCopy(nil, 0, rawMetaData) as NSMutableDictionary
        let exifData = metaData.value(forKey: "{Exif}") as? NSMutableDictionary
//        print("EXIF DATA: \(exifData)")
        let brightnessValue = (exifData as AnyObject).object(forKey: "BrightnessValue")
        self.brightnessLabel.text = String(describing: brightnessValue!)
        let a = pow(10.0, (brightnessValue as! Float))
        let b = Float32(Int(a * 10)) * 10
        self.hertzLabelOutlet.text = String(b)
        hertz = b
    }
    
    
    func checkBrightness() {
        // Get ambient brightness.
        
        // Convert brightness to frequency.
        
        // Give frequency and play audio.
//        FMSynthesizer.sharedSynth().play(440.0, modulatorAmplitude: 0.8)
//        playSineWaveSound(hertz: 440.1)
    }
    
    // 音量上げる
    @IBAction func volUpAction(_ sender: UIButton) {
    }

    // 音量下げる
    @IBAction func volDownAction(_ sender: UIButton) {
    }


}
