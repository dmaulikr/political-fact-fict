//
//  MultiPlayerTeamReadyViewController.swift
//  PoliticalFactFiction
//
//  Created by Jason La on 8/20/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import Firebase
import UIKit
import AVFoundation

class MultiPlayerTeamReadyViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var teamNumLabel: UILabel!
    @IBOutlet weak var roundNumLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var tapSound: AVAudioPlayer?
    
    let rootRef = FIRDatabase.database().reference()
    var highscore: Int = 0
    var num_entries: Int = 1
    var teamNum: Int = 1
    var roundNum: Int = 1
    var numRounds: Int = 1
    var timePerQ: Int = 10
    
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
    
    @IBAction func goBack(sender: AnyObject) {
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
        
        rootRef.child("num-entries").observeEventType(.Value) { (snap: FIRDataSnapshot) in
            if let en = snap.value?.description {
                self.num_entries = Int(en)!
            }
        }
        
        self.teamNumLabel.text = "Team \(self.teamNum) Ready?"
        self.roundNumLabel.text = "Round \(self.roundNum)"
        
        if (teamNum == 2) {
            self.backButton.hidden = true
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
        if (segue.identifier == "mp_questionSegue") {
            let QuestionContainerVc = segue.destinationViewController as! SP_QuestionContainer_ViewController
            QuestionContainerVc.num_entries = self.num_entries
            QuestionContainerVc.teamNum = self.teamNum
            QuestionContainerVc.timeLimit = Double(self.timePerQ)
            QuestionContainerVc.numRounds = self.numRounds
            QuestionContainerVc.roundNum = self.roundNum
            
            QuestionContainerVc.teamOneScore = self.teamOneScore
            QuestionContainerVc.teamOneRounds = self.teamOneRounds
            QuestionContainerVc.teamOneSeenStatements = self.teamOneSeenStatements
            QuestionContainerVc.teamOneUnseenStatements = self.teamOneUnseenStatements
            QuestionContainerVc.teamOneStatementList = self.teamOneStatementList
            QuestionContainerVc.teamOneExplanationList = self.teamOneExplanationList
            QuestionContainerVc.teamOneAnswerList = self.teamOneAnswerList
            QuestionContainerVc.teamOneSourceList = self.teamOneSourceList
            
            QuestionContainerVc.teamTwoScore = self.teamTwoScore
            QuestionContainerVc.teamTwoRounds = self.teamTwoRounds
            QuestionContainerVc.teamTwoSeenStatements = self.teamTwoSeenStatements
            QuestionContainerVc.teamTwoUnseenStatements = self.teamTwoUnseenStatements
            QuestionContainerVc.teamTwoStatementList = self.teamTwoStatementList
            QuestionContainerVc.teamTwoExplanationList = self.teamTwoExplanationList
            QuestionContainerVc.teamTwoAnswerList = self.teamTwoAnswerList
            QuestionContainerVc.teamTwoSourceList = self.teamTwoSourceList
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
