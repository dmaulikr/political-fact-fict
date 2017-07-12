//
//  SinglePlayerViewController.swift
//  PoliticalFactFiction
//
//  Created by Thang Nguyen on 7/9/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class SinglePlayerViewController: UIViewController {

    let rootRef = FIRDatabase.database().reference()
    var highscore: Int = 0
    var num_entries : Int = 1
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    var tapSound : AVAudioPlayer?
    
    @IBAction func goback() {
        self.navigationController!.popViewControllerAnimated(true)
        self.tapSound?.play()
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
        
        // Read high score from stable storage if available
        let defaults = NSUserDefaults.standardUserDefaults()
        let hs = defaults.integerForKey("userHighScore")
        if hs != 0 {
            self.highscore = hs
        }
        print("Read high score from NSUserDefaults: \(hs)")
        self.scoreLabel.text = "High Score: \(self.highscore)"
        
        // Setup button tap sound
        if let tapSound = setupAudioPlayerWithFile("tap-warm", type: "wav") {
            self.tapSound = tapSound
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if (segue.identifier == "sp_questionSegue") {
            let QuestionContainerVc = segue.destinationViewController as! SP_QuestionContainer_ViewController
            QuestionContainerVc.num_entries = self.num_entries
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
