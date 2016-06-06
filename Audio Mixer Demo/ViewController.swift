//
//  ViewController.swift
//  Audio Mixer Demo
//
//  Created by ANDREW SMITH on 13/03/2015.
//  Copyright (c) 2015 Robot Loves You. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet var disableEffectsButton: UIButton!
    
    var engine: AVAudioEngine!
    var player: AVAudioPlayerNode!
    var buffer: AVAudioPCMBuffer!
    var disableEffects: Bool!
    var distortionA: AVAudioUnitDistortion!
    var distortionB: AVAudioUnitDistortion!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        player.volume = 0.5
        
        self.disableEffects = false

        let path = NSBundle.mainBundle().pathForResource("farah-faucet", ofType: "wav")!
        let url = NSURL.fileURLWithPath(path)
        
        let file = try? AVAudioFile(forReading: url)
        buffer = AVAudioPCMBuffer(PCMFormat: file!.processingFormat, frameCapacity: AVAudioFrameCount(file!.length))
        try! file!.readIntoBuffer(buffer)
        
        distortionA = AVAudioUnitDistortion()
        distortionA.loadFactoryPreset(AVAudioUnitDistortionPreset.MultiDecimated2)
        distortionA.wetDryMix = 100

        distortionB = AVAudioUnitDistortion()
        distortionB.loadFactoryPreset(AVAudioUnitDistortionPreset.SpeechRadioTower)
        distortionB.wetDryMix = 10
        
        engine.attachNode(player)
        engine.attachNode(distortionA)
        engine.attachNode(distortionB)
        
        // Connect player to the distortion
        engine.connect(player, to: distortionA, format: buffer.format)
        // Connect the distortion to the mixer
        engine.connect(distortionA, to: distortionB, format: buffer.format)
        // Connect the reverb to the mixer
        engine.connect(distortionB, to: engine.mainMixerNode, format: buffer.format)
        player.scheduleBuffer(buffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions.Loops, completionHandler: nil)
        
        // Start the audio engine
        engine.prepare()
        try! engine.start()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func togglePlayPauseHidden() {
        pauseButton.hidden = !pauseButton.hidden
        playButton.hidden = !playButton.hidden
    }
    
    @IBAction func playButtonTapped(sender: UIButton) {
        player.play()
        togglePlayPauseHidden()
    }

    @IBAction func pauseButtonTapped(sender: UIButton) {
        player.pause()
        togglePlayPauseHidden()
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        player.volume = sender.value
//        playerB.volume = 1.0 - sender.value
    }

    @IBAction func disableDecimatedTapped(sender: UIButton) {
        NSLog("disableDecimatedTapped:")

            /* try 1
             engine.stop()
             engine.detachNode(distortionA)
             player.scheduleBuffer(buffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions.Loops, completionHandler: nil)
             engine.connect(player, to: distortionB, format: buffer.format)
             engine.connect(distortionB, to: engine.mainMixerNode, format: buffer.format)
             engine.prepare()
             try! engine.start()
             player.play()
             */
            
            // try 2
            engine.disconnectNodeOutput(distortionA)
            engine.connect(player, to: distortionB, format: buffer.format)
            engine.stop()
            engine.detachNode(distortionA)
            try! engine.start()
            player.play()
            
    }
}

