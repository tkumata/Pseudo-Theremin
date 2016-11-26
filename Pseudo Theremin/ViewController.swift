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
    
    // MARK: - For sine wave sound.
    var audioHertz: Float32 = 440.1
    let audioRepeatPeriod: Double = 0.1
    let audioEngine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    var audioBuffer: AVAudioPCMBuffer!
    
    // MARK: - For camera.
    var cameraInput: AVCaptureDeviceInput!
    var cameraOutput = AVCaptureVideoDataOutput()
    var cameraSession = AVCaptureSession()
    var cameraDevice: AVCaptureDevice!
    var i: Int = 1

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1.0)
        
        // Hertz label attribute.
        hertzLabelOutlet.layer.borderWidth = 1.0
        hertzLabelOutlet.layer.cornerRadius = 5.0
        hertzLabelOutlet.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
//        hertzLabelOutlet.isHidden = true
        
        // Brightness label attribute.
        brightnessLabel.layer.borderWidth = 1.0
        brightnessLabel.layer.cornerRadius = 5.0
        brightnessLabel.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
//        brightnessLabel.isHidden = true
        
        // Up button attribute.
        volUpButtonOutlet.tintColor = .black
        volUpButtonOutlet.layer.borderWidth = 5.0
        volUpButtonOutlet.layer.cornerRadius = 10.0
        volUpButtonOutlet.layer.borderColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        volUpButtonOutlet.layer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1.0).cgColor
        volUpButtonOutlet.layer.zPosition = 2
        
        // Down button attribute.
        volDownButtonOutlet.tintColor = .black
        volDownButtonOutlet.layer.borderWidth = 5.0
        volDownButtonOutlet.layer.cornerRadius = 10.0
        volDownButtonOutlet.layer.borderColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        volDownButtonOutlet.layer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1.0).cgColor
        volDownButtonOutlet.layer.zPosition = 2
        
        // Background of up/down button.
        buttonBackground.text = ""
        buttonBackground.layer.borderWidth = 1.0
        //buttonBackground.layer.cornerRadius = 10.0
        buttonBackground.layer.borderColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0).cgColor
        //buttonBackground.layer.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0).cgColor
        buttonBackground.backgroundColor = .white
        buttonBackground.layer.zPosition = 0

        // MARK: Preparing camera.
        cameraSession.sessionPreset = AVCaptureSessionPresetHigh
        let devicesSession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInDuoCamera,
                                                                           .builtInTelephotoCamera,
                                                                           .builtInWideAngleCamera],
                                                             mediaType: AVMediaTypeVideo,
                                                             position: .front)
        
        for caputureDevice in (devicesSession?.devices)! {
            // if() で確実に front が取得できるように。
            if caputureDevice.position == AVCaptureDevicePosition.front {
                cameraDevice = caputureDevice
            }
        }
        
        do {
            cameraInput = try AVCaptureDeviceInput(device: cameraDevice)
        } catch let error as NSError {
            print(error)
        }
        
        // カメラの入力が存在すれば、
        if cameraSession.canAddInput(cameraInput) {
            // Session に追加する。
            cameraSession.addInput(cameraInput)
            
            // カメラの出力が存在すれば、
            if cameraSession.canAddOutput(cameraOutput) {
                // Session に追加する。
                cameraSession.addOutput(cameraOutput)
                
                // 出力のプロパティを設定する。
                cameraOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)]
                cameraOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
                cameraOutput.alwaysDiscardsLateVideoFrames = true
                
                // Session を開始する。
                cameraSession.startRunning()
            }
        }
        
        // MARK: Call function which setting up audio engine.
        setupAudioEngine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Setup audio engine.
    func setupAudioEngine() {
        let audioFormat = audioPlayerNode.outputFormat(forBus: 0)
        let mixer = audioEngine.mainMixerNode
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: mixer, format: audioFormat)
        
        do {
            try audioEngine.start()
            audioPlayerNode.volume = 0.5
            audioPlayerNode.play()
        } catch let error {
            print(error)
        }
    }
    
    // MARK: - Making audio buffer for sine wave sound.
    func changeFrequency() {
        let audioFormat = audioPlayerNode.outputFormat(forBus: 0)
        let sampleRate = Float(audioFormat.sampleRate)
        let length = Float(audioRepeatPeriod) * sampleRate
        
        // Making audio buffer.
        audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: UInt32(length))
        audioBuffer.frameLength = UInt32(length)
        let channels = Int(audioFormat.channelCount)
        
        for ch in 0 ..< channels { // 左右チャンネル分を回す。重点。
            let samples = audioBuffer.floatChannelData?[ch]
            
            for n in 0 ..< Int(audioBuffer.frameLength) {
                samples?[n] = sinf(Float(2.0 * M_PI) * audioHertz * Float(n) / sampleRate)
            }
        }
        
        // Schedule.
        //player.scheduleBuffer(audioBuffer, at: nil, options: .loops, completionHandler: nil)
        audioPlayerNode.scheduleBuffer(audioBuffer)
        
        // Print to label.
        self.hertzLabelOutlet.text = "Freq: " + String(audioHertz) + " Hz"
    }
    
    // MARK: - Meta data から輝度を取得。
    func captureOutput(_ captureOutput: AVCaptureOutput,
                       didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        if i > 100 {
            i = 1
        }
        
        // CPU 負荷を抑える単純な仕掛け。
        // これで CPU usage 10% -> 4.5% へ
        if i % 3 == 0 {
            let rawMetaData = CMCopyDictionaryOfAttachments(nil,
                                                            sampleBuffer,
                                                            CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
            let metaData = CFDictionaryCreateMutableCopy(nil, 0, rawMetaData) as NSMutableDictionary
            let exifData = metaData.value(forKey: "{Exif}") as? NSMutableDictionary
            // print("EXIF DATA: \(exifData)")
            
            // Exif から BrightnessValue だけ取り出す。
            let brightnessValue = (exifData as AnyObject).object(forKey: "BrightnessValue")
            self.brightnessLabel.text = String(describing: brightnessValue!)
            
            // TODO: 輝度から周波数へ変換するアルゴリズムも考える。
            // 現状は単純に pow() してるだけ。
            let rawHertz = pow(10.0, (brightnessValue as! Float))
            // 小数点三桁以降は切り捨て。x.xx まで。
            let convertedHertz = Float32(Int(rawHertz * 10)) * 10
            audioHertz = convertedHertz
            changeFrequency()
        }
        
        i += 1
    }
    
    // MARK: -
//    func hoge() {
//        FMSynthesizer.sharedSynth().play(440.0, modulatorAmplitude: 0.8)
//        playSineWaveSound(hertz: 440.1)
//    }
    
    // MARK: - 音量上げる。
    @IBAction func volUpAction(_ sender: UIButton) {
        self.audioPlayerNode.volume += 0.1
    }

    // MARK: - 音量下げる。
    @IBAction func volDownAction(_ sender: UIButton) {
        self.audioPlayerNode.volume -= 0.1
    }


}
