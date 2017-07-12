//
//  MultiplayerOptionsViewController.swift
//  PoliticalFactFiction
//
//  Created by Wesley Minner on 7/15/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import Firebase
import UIKit
import AVFoundation

class MultiplayerOptionsViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var rounds: UILabel!
    
    @IBOutlet weak var timeSliderValue: UISlider!
    @IBOutlet weak var roundsSliderValue: UISlider!
    
    var num_entries: Int = 1
    var numRounds: Int = 3
    var timePerQ: Int = 10
    var tapSound: AVAudioPlayer?
    
    @IBAction func goback() {
        self.tapSound?.play()
        self.navigationController!.popViewControllerAnimated(true)
    }
    @IBAction func pressStartButton() {
        self.tapSound?.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startButton.layer.shadowOpacity = 0.9
        startButton.layer.shadowRadius = 2.0
        startButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        startButton.layer.borderWidth = 2.0
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let mhs = defaults.integerForKey("multiHighScore")

        print("Read high score from NSUserDefaults: \(mhs)")
        self.scoreLabel.text = "High Score: \(mhs)"
        self.rounds.text = "Number of rounds: 3"
        self.time.text = "Seconds per question: 10"
        
        // Setup button tap sound
        if let tapSound = setupAudioPlayerWithFile("tap-warm", type: "wav") {
            self.tapSound = tapSound
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func timeSliderValueChanged(sender: UISlider) {

        let selectedValue = Int(sender.value)
        
        timePerQ = selectedValue
        time.text = "Seconds per question: " + String(stringInterpolationSegment: selectedValue)
    }

    @IBAction func roundsSliderValueChanged(sender: UISlider) {
        
        var selectedValue = Int(sender.value)
        
        if selectedValue == 0 {
            selectedValue = selectedValue + 1
        } else if selectedValue == 1 {
            selectedValue = selectedValue + 2
        } else {
            selectedValue = selectedValue + 3
        }
        
        self.numRounds = selectedValue
        rounds.text = "Number of rounds: " + String(stringInterpolationSegment: selectedValue)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        super.prepareForSegue(segue, sender: sender)
        if (segue.identifier == "mTeamReadySegue") {
            let teamReadyVc = segue.destinationViewController as! MultiPlayerTeamReadyViewController
            teamReadyVc.num_entries = self.num_entries
            teamReadyVc.numRounds = self.numRounds
            teamReadyVc.timePerQ = self.timePerQ
        }

        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */

}
