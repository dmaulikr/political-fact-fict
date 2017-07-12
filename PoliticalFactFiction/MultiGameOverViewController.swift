//
//  MultiGameOverViewController.swift
//  PoliticalFactFiction
//
//  Created by Jason La on 8/23/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import AVFoundation

class MultiGameOverViewController: UIViewController {
    
    var teamOneRounds: Int = 0
    var teamOneSeenStatements: [Int] = []
    var teamOneStatementList: [Int : String] = [:]
    var teamOneExplanationList: [Int : String] = [:]
    var teamOneAnswerList: [Int : String] = [:]
    var teamOneSourceList: [Int : String] = [:]
    
    var teamTwoRounds: Int = 0
    var teamTwoSeenStatements: [Int] = []
    var teamTwoStatementList: [Int : String] = [:]
    var teamTwoExplanationList: [Int : String] = [:]
    var teamTwoAnswerList: [Int : String] = [:]
    var teamTwoSourceList: [Int : String] = [:]
    
    var tapSound: AVAudioPlayer?
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var teamOneButton: UIButton!
    @IBOutlet weak var teamTwoButton: UIButton!
    
    @IBAction func pressDoneButton() {
        self.tapSound?.play()
    }
    @IBAction func pressTeamReviewButton() {
        self.tapSound?.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.teamOneRounds > self.teamTwoRounds) {
            self.winnerLabel.text = "Team 1 Wins!"
        } else if (self.teamTwoRounds > self.teamOneRounds) {
            self.winnerLabel.text = "Team 2 Wins!"
        } else {
            self.winnerLabel.text = "It's a tie!"
        }
        
        teamOneButton.layer.shadowOpacity = 0.9
        teamOneButton.layer.shadowRadius = 2.0
        teamOneButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        teamOneButton.layer.borderWidth = 2.0
        
        teamTwoButton.layer.shadowOpacity = 0.9
        teamTwoButton.layer.shadowRadius = 2.0
        teamTwoButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        teamTwoButton.layer.borderWidth = 2.0
        
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
        
        if (segue.identifier == "teamOneReviewSegue") {
            super.prepareForSegue(segue, sender: sender)
            let GameOverVc = segue.destinationViewController as! GameOverViewController
            GameOverVc.teamNum = 1
            GameOverVc.seenStatements = self.teamOneSeenStatements
            GameOverVc.statementList = self.teamOneStatementList
            GameOverVc.explanationList = self.teamOneExplanationList
            GameOverVc.answerList = self.teamOneAnswerList
            GameOverVc.sourceList = self.teamOneSourceList
        }
        
        if (segue.identifier == "teamTwoReviewSegue") {
            super.prepareForSegue(segue, sender: sender)
            let GameOverVc = segue.destinationViewController as! GameOverViewController
            GameOverVc.teamNum = 2
            GameOverVc.seenStatements = self.teamTwoSeenStatements
            GameOverVc.statementList = self.teamTwoStatementList
            GameOverVc.explanationList = self.teamTwoExplanationList
            GameOverVc.answerList = self.teamTwoAnswerList
            GameOverVc.sourceList = self.teamTwoSourceList
        }

    }
    

}
