//
//  EndRoundViewController.swift
//  PoliticalFactFiction
//
//  Created by Jason La on 8/23/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import AVFoundation

class EndRoundViewController: UIViewController {
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var roundNumLabel: UILabel!
    @IBOutlet weak var teamOneScoreLabel: UILabel!
    @IBOutlet weak var teamTwoScoreLabel: UILabel!
    @IBOutlet weak var teamOneRoundsLabel: UILabel!
    @IBOutlet weak var teamTwoRoundsLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    var tapSound: AVAudioPlayer?
    
    var roundNum: Int = 1
    var numRounds: Int = 1
    var timePerQ: Int = 0
    var num_entries: Int = 0
    var gameOver: Bool = false
    var teamNum: Int = 0
    
    var teamOneScore: Int = 0
    var teamOneRounds: Int = 0
    var teamOneSeenStatements: [Int] = []
    var teamOneUnseenStatements: [Int] = []
    var teamOneStatementList: [Int : String] = [:]
    var teamOneExplanationList: [Int : String] = [:]
    var teamOneAnswerList: [Int : String] = [:]
    var teamOneSourceList: [Int : String] = [:]
    
    var teamTwoScore: Int = 0
    var teamTwoRounds: Int = 0
    var teamTwoSeenStatements: [Int] = []
    var teamTwoUnseenStatements: [Int] = []
    var teamTwoStatementList: [Int : String] = [:]
    var teamTwoExplanationList: [Int : String] = [:]
    var teamTwoAnswerList: [Int : String] = [:]
    var teamTwoSourceList: [Int : String] = [:]
    
    @IBAction func continueButtonFunc() {
        print("continue")
        self.tapSound?.play()
        if gameOver {
            self.performSegueWithIdentifier("multiGameOverSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("nextRoundSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.layer.shadowOpacity = 0.9
        continueButton.layer.shadowRadius = 2.0
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        continueButton.layer.borderWidth = 2.0
        
        if(self.teamOneScore == self.teamTwoScore) {
            self.teamOneRounds += 1
            self.teamTwoRounds += 1
            self.winnerLabel.text = "It's a tie!"
        } else if (self.teamOneScore > self.teamTwoScore) {
            self.teamOneRounds += 1
            self.winnerLabel.text = "Team 1 takes the round!"
        } else {
            self.teamTwoRounds += 1
            self.winnerLabel.text = "Team 2 takes the round!"
        }
        
        self.roundNumLabel.text = "Round \(self.roundNum)"
        self.teamOneScoreLabel.text = "Team 1: \(self.teamOneScore)"
        self.teamTwoScoreLabel.text = "Team 2: \(self.teamTwoScore)"

        switch self.teamOneRounds {
        case 3:
            self.teamOneRoundsLabel.text = "***"
        case 2:
            self.teamOneRoundsLabel.text = "**"
        case 1:
            self.teamOneRoundsLabel.text = "*"
        default:
            self.teamOneRoundsLabel.text = ""
        }
        
        switch self.teamTwoRounds {
        case 3:
            self.teamTwoRoundsLabel.text = "***"
        case 2:
            self.teamTwoRoundsLabel.text = "**"
        case 1:
            self.teamTwoRoundsLabel.text = "*"
        default:
            self.teamTwoRoundsLabel.text = ""
        }
        
        switch self.numRounds {
        case 5:
            if self.teamOneRounds == 3 || self.teamTwoRounds == 3 {
                gameOver = true
            }
        case 3:
            if self.teamOneRounds == 2 || self.teamTwoRounds == 2 {
                gameOver = true
            }
        case 1:
            if self.teamOneRounds == 1 || self.teamTwoRounds == 1 {
                gameOver = true
            }
        default:
            gameOver = true
        }
        
        self.roundNum += 1
        
        if(self.roundNum > self.numRounds) {
            gameOver = true;
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if (segue.identifier == "nextRoundSegue") {
            let TeamyReadyVc = segue.destinationViewController as! MultiPlayerTeamReadyViewController
            
            TeamyReadyVc.num_entries = self.num_entries
            TeamyReadyVc.teamNum = 1
            TeamyReadyVc.timePerQ = self.timePerQ
            TeamyReadyVc.numRounds = self.numRounds
            TeamyReadyVc.roundNum = self.roundNum
            
            TeamyReadyVc.teamOneRounds = self.teamOneRounds
            TeamyReadyVc.teamOneSeenStatements = self.teamOneSeenStatements
            TeamyReadyVc.teamOneUnseenStatements = self.teamOneUnseenStatements
            TeamyReadyVc.teamOneStatementList = self.teamOneStatementList
            TeamyReadyVc.teamOneExplanationList = self.teamOneExplanationList
            TeamyReadyVc.teamOneAnswerList = self.teamOneAnswerList
            TeamyReadyVc.teamOneSourceList = self.teamOneSourceList
            
            TeamyReadyVc.teamTwoRounds = self.teamTwoRounds
            TeamyReadyVc.teamTwoSeenStatements = self.teamTwoSeenStatements
            TeamyReadyVc.teamTwoUnseenStatements = self.teamTwoUnseenStatements
            TeamyReadyVc.teamTwoStatementList = self.teamTwoStatementList
            TeamyReadyVc.teamTwoExplanationList = self.teamTwoExplanationList
            TeamyReadyVc.teamTwoAnswerList = self.teamTwoAnswerList
            TeamyReadyVc.teamTwoSourceList = self.teamTwoSourceList
        }
        if (segue.identifier == "multiGameOverSegue") {
            let MultiGameOverVc = segue.destinationViewController as! MultiGameOverViewController
            
            MultiGameOverVc.teamOneRounds = self.teamOneRounds
            MultiGameOverVc.teamOneSeenStatements = self.teamOneSeenStatements
            MultiGameOverVc.teamOneStatementList = self.teamOneStatementList
            MultiGameOverVc.teamOneExplanationList = self.teamOneExplanationList
            MultiGameOverVc.teamOneAnswerList = self.teamOneAnswerList
            MultiGameOverVc.teamOneSourceList = self.teamOneSourceList
            
            MultiGameOverVc.teamTwoRounds = self.teamTwoRounds
            MultiGameOverVc.teamTwoSeenStatements = self.teamTwoSeenStatements
            MultiGameOverVc.teamTwoStatementList = self.teamTwoStatementList
            MultiGameOverVc.teamTwoExplanationList = self.teamTwoExplanationList
            MultiGameOverVc.teamTwoAnswerList = self.teamTwoAnswerList
            MultiGameOverVc.teamTwoSourceList = self.teamTwoSourceList
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    */

}
