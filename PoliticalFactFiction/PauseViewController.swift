//
//  PauseViewController.swift
//  PoliticalFactFiction
//
//  Created by Wesley Minner on 7/15/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import AVFoundation

class PauseViewController: UIViewController {

    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var teamRoundLabel: UILabel!
    
    var playerScore : Int = 0
    var QuestionContainerVc: SP_QuestionContainer_ViewController?
    
    var tapSound: AVAudioPlayer?
    
    //multiplayer
    var teamNum: Int = 0
    var roundNum: Int = 0
    
    @IBAction func resumeGame() {
        self.tapSound?.play()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func quitGame() {
        self.tapSound?.play()
        let startView = self.storyboard!.instantiateViewControllerWithIdentifier("startScreen") as UIViewController
        self.presentingViewController!.showViewController(startView, sender: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resumeButton.layer.shadowOpacity = 0.9
        resumeButton.layer.shadowRadius = 2.0
        resumeButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        resumeButton.layer.borderWidth = 2.0
        quitButton.layer.shadowOpacity = 0.9
        quitButton.layer.shadowRadius = 2.0
        quitButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        quitButton.layer.borderWidth = 2.0
        
        self.scoreLabel.text = "Score: \(self.playerScore)"
        
        if(teamNum > 0) {
            self.teamRoundLabel.text = "Team \(self.teamNum) - Round \(self.roundNum)"
        } else {
            self.teamRoundLabel.text = ""
        }
        
        // Setup button tap sound
        if let tapSound = setupAudioPlayerWithFile("tap-warm", type: "wav") {
            self.tapSound = tapSound
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
