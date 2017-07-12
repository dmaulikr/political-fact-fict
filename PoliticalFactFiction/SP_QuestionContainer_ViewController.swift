//
//  SP_QuestionContainer_ViewController.swift
//  PoliticalFactFiction
//
//  Created by Thang Nguyen on 7/9/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class SP_QuestionContainer_ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var teamNumLabel: UILabel!
    
    var tapSound: AVAudioPlayer?
    var correctSound: AVAudioPlayer?
    var wrongSound: AVAudioPlayer?
    
    let rootRef = FIRDatabase.database().reference()
    let subviewList = ["Fiction", "Statement", "Fact"]
    
    var playerScore: Int = 0            // Number of questions player answered correctly
    var playerHearts: Int = 5           // Errors the player can make remaining
    var statementNo: Int = 1            // Number of currently shown statement
    var num_entries: Int = 1            // Number of statements in the database
    var answer = ""                     // Answer to the statement (either 'T' for true/fact or 'F' for false/fiction)
    var timeLimit: Double = 10.0        // Time player has to give an answer
    var timeDecreaseThresh : Int = 10   // Time decreases after player gets more than this number of points
    var timeDecreaseIncrement : Int = 3 // Decrease time each time player receives this many points
    var minTime : Double = 3.0
    var seenStatements: [Int] = []      // Contains statements player has received so far (for reference list on the game over screen)
    var unseenStatements: [Int] = []    // Contains statements player has not received so far (to help avoid duplicates when choosing next statement)
    
    var paused: Bool = false
    var startTime: CFTimeInterval = 0.0       // Keeps track of the time at which the statement was started
    var runningTime: CFTimeInterval = 0.0     // Keeps track of total time running for each statement
    
    var statementList: [Int : String] = [:]
    var explanationList: [Int : String] = [:]
    var answerList: [Int : String] = [:]
    var sourceList: [Int : String] = [:]
    
    //variables for multiplayer
    var teamNum: Int = 0
    var numRounds: Int = 0
    var roundNum: Int = 0
    
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
    
    // Create the three views used in the swipe container view
    let FictionVc :FictionViewController =  FictionViewController(nibName: "FictionViewController", bundle: nil)
    let StatementVc :StatementViewController =  StatementViewController(nibName: "StatementViewController", bundle: nil)
    let FactVc :FactViewController =  FactViewController(nibName: "FactViewController", bundle: nil)
    
    // No longer using because it breaks pausing
    // See "resumeGame" function in PauseViewController for replacement
//    @IBAction func resumeGame(unwindSegue: UIStoryboardSegue) {
//        resumeLayer(StatementVc.clockHand.layer)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootRef.child("\(self.statementNo)").child("answer").observeEventType(.Value) { (snap: FIRDataSnapshot) in
            self.answer = (snap.value?.description)!
        }
        
        // Initialize unseen statements list
        if (self.teamNum == 0) {
            unseenStatements += 1...self.num_entries
        } else if (self.teamNum == 1 && self.roundNum == 1) {
            teamOneUnseenStatements += 1...self.num_entries
        } else if (self.teamNum == 2 && self.roundNum == 1) {
            teamTwoUnseenStatements += 1...self.num_entries
        }

        if(teamNum == 0) {
            getNewStatement()
        } else if (teamNum == 1) {
            teamOneGetNewStatement()
        } else {
            teamTwoGetNewStatement()
        }
        
        let scrollWidth: CGFloat = self.view.frame.width
        let scrollHeight: CGFloat = self.view.frame.height
        
        // Setup subview frame sizes and their alignment
        FictionVc.view.frame = CGRectMake(0, 0, scrollWidth, scrollHeight)
        StatementVc.view.frame = CGRectMake(scrollWidth, 0, scrollWidth, scrollHeight)
        FactVc.view.frame = CGRectMake(scrollWidth*2, 0, scrollWidth, scrollHeight)
        
        // Add in each view to the container view hierarchy
        // Add them in opposite order since the view hieracrhy is a stack
        self.addChildViewController(self.FactVc)         // Index 2
        self.scrollView!.addSubview(self.FactVc.view)
        self.FactVc.didMoveToParentViewController(self)
        
        self.addChildViewController(self.StatementVc)    // Index 1
        self.scrollView!.addSubview(self.StatementVc.view)
        self.StatementVc.didMoveToParentViewController(self)
        
        self.addChildViewController(self.FictionVc)      // Index 0
        self.scrollView!.addSubview(self.FictionVc.view)
        self.FictionVc.didMoveToParentViewController(self)
        
        // Set the size of the scroll view that contains the frames
        self.scrollView!.contentSize = CGSizeMake(scrollWidth * 3, scrollHeight)
        
        // Center the scroll view
        self.scrollView!.contentOffset = CGPointMake(scrollWidth, 0)
        
        // Set up scroll view delegate
        self.scrollView!.delegate = self
        
        // Start clock animation for initial statement
        StatementVc.rotateClockHand(self.timeLimit)
        
        if(self.teamNum == 0) {
            self.teamNumLabel.text = ""
        } else {
            self.teamNumLabel.text = "Team \(self.teamNum)"
            print("team no: \(self.teamNum)")
        }
        
        // Setup sounds
        if let tapSound = setupAudioPlayerWithFile("tap-warm", type: "wav") {
            self.tapSound = tapSound
        }
        if let correctSound = setupAudioPlayerWithFile("beep-positive", type: "wav") {
            self.correctSound = correctSound
        }
        if let wrongSound = setupAudioPlayerWithFile("beep-negative", type: "wav") {
            self.wrongSound = wrongSound
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.paused {
            self.resumeLayer(self.StatementVc.clockHand.layer)
        }
    }
    
    // **************************************************************************
    // Touch Button Functions (alternative to swiping)
    // **************************************************************************
    
    func touchFactButton() {
        // Simulate a swipe to the right
        self.pauseButton.enabled = false
        self.scrollView!.slideInFromRight(0.3)
        self.scrollView!.contentOffset = CGPointMake(self.view.frame.width*2, 0)
        delay(0.3) {
            self.scrollViewDidEndDecelerating(self.scrollView)
        }
    }
    
    func touchFictionButton() {
        // Simulate a swipe to the left
        self.pauseButton.enabled = false
        self.scrollView!.slideInFromLeft(0.3)
        self.scrollView!.contentOffset = CGPointMake(0, 0)
        delay(0.3) {
            self.scrollViewDidEndDecelerating(self.scrollView)
        }
    }
    
    // **************************************************************************
    // Pause/Resume Functions
    // **************************************************************************
    
    @IBAction func pauseGame() {
        self.pauseLayer(self.StatementVc.clockHand.layer)
        self.tapSound?.play()
    }
    
    func pauseLayer(layer: CALayer) {
        self.paused = true
        
        let pausedTime: CFTimeInterval = CACurrentMediaTime()
        let runningTimeSegment: CFTimeInterval = pausedTime - self.startTime
        // Keep track of total time spent on question
        // (in case of multiple pauses for a single question)
        self.runningTime += runningTimeSegment
    }
    
    func resumeLayer(layer: CALayer) {
        self.paused = false
        
        StatementVc.rotateClockHand(self.timeLimit, resume: self.runningTime)
    }
    
    // **************************************************************************
    // Delegates for scrollView
    // **************************************************************************
    
    // Delegate for end decelerating from scrolling
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // Find out what page we stopped on
        let pageIndex : Int = getPageIndex()

        // Decide what to do based on page stopped on
        switch pageIndex {
        // Fiction choice
        case 0:
            self.StatementVc.resetClockHand()
        // Statement
        case 1:
            break
        // Fact choice
        case 2:
            self.StatementVc.resetClockHand()
        default:
            gameover()
        }
    }
    
    // **************************************************************************
    // Animation Callbacks
    // **************************************************************************
    
    // Animation timer expired or was reset
    // If this is called while user is on the statement screen, then they lose a heart
    // Otherwise if they are on the correct fact/fiction screen (and still dragging), then take that as their answer
    //
    // Inputs:
    //   finished: says if the clock animation finished or not
    func animationComplete(finished: Bool) {
        
        let pageIndex = getPageIndex()
        print("Timeout on page \(pageIndex)")
        switch pageIndex {
        
        // Fiction choice
        case 0:
            // Answered correctly
            
            // Disable scroll and pause (otherwise weird stuff happens)
            self.scrollView!.scrollEnabled = false
            self.pauseButton.enabled = false
            
            // Timeout occured, slide to make transition nice
            if finished {
                self.scrollView!.slideInFromLeft(0.5)
            }
            
            self.scrollView!.contentOffset = CGPointMake(0, 0)
            // Answered correctly
            if self.answer == "F" {
                self.FictionVc.responseString = "Correct!"
                self.FictionVc.answerString = "Answer: Fiction"
                self.playerScore += 1
                self.updateScores()
                self.correctSound?.play()
            }
            // Answered incorrectly
            else {
                self.FictionVc.responseString = "Wrong!"
                self.FictionVc.answerString = "Answer: Fact"
                self.playerHearts -= 1
                self.updateHearts()
                self.wrongSound?.play()
            }
            self.FictionVc.revealAnswer()
            
            // Update labels and get new statement (if hearts left)
            if self.playerHearts > 0 {
                if(self.teamNum == 0) {
                    self.getNewStatement()
                } else if (self.teamNum == 1) {
                    self.teamOneGetNewStatement()
                } else {
                    self.teamTwoGetNewStatement()
                }
                // Slide transition back to Statement view
                delay(1.0) {
                    // print("Transitioning back to Statement View")
                    self.scrollView!.slideInFromRight(0.5)
                    self.scrollView!.contentOffset = CGPointMake(self.view.frame.width, 0)
                    self.FictionVc.hideAnswer()
                    
                    // Re-enable scroll and pause button
                    self.scrollView!.scrollEnabled = true
                    self.pauseButton.enabled = true
                    
                    // Restart clock for next statement
                    self.StatementVc.rotateClockHand(self.timeLimit)
                }
            }
        // Statement
        case 1:
            // Disable scroll and pause (otherwise weird stuff happens)
            self.scrollView!.scrollEnabled = false
            self.pauseButton.enabled = false
            self.playerHearts -= 1
            updateHearts()
            
            // Slide to reveal answer
            if self.answer == "T" {
                self.scrollView!.slideInFromRight(0.5)
                self.scrollView!.contentOffset = CGPointMake(self.view.frame.width*2, 0)
                self.FactVc.responseString = "Time Up!"
                self.FactVc.answerString = "Answer: Fact"
                self.FactVc.revealAnswer()
                self.wrongSound?.play()
                
                // If player not dead, then get a new statement and continue game
                if self.playerHearts > 0 {
                    if(self.teamNum == 0) {
                        self.getNewStatement()
                    } else if (self.teamNum == 1) {
                        self.teamOneGetNewStatement()
                    } else {
                        self.teamTwoGetNewStatement()
                    }
                    delay(1.0) {
                        // print("Transitioning back to Statement View")
                        self.scrollView!.slideInFromLeft(0.5)
                        self.scrollView!.contentOffset = CGPointMake(self.view.frame.width, 0)
                        self.FactVc.hideAnswer()
                        
                        // Re-enable scroll and pause button
                        self.scrollView!.scrollEnabled = true
                        self.pauseButton.enabled = true
                        
                        // Restart clock for next statement
                        self.StatementVc.rotateClockHand(self.timeLimit)
                    }
                }
            } else if self.answer == "F" {
                self.scrollView!.slideInFromLeft(0.5)
                self.scrollView!.contentOffset = CGPointMake(0, 0)
                self.FictionVc.responseString = "Time Up!"
                self.FictionVc.answerString = "Answer: Fiction"
                self.FictionVc.revealAnswer()
                self.wrongSound?.play()
                
                // If player not dead, then get a new statement and continue game
                if self.playerHearts > 0 {
                    if(self.teamNum == 0) {
                        self.getNewStatement()
                    } else if (self.teamNum == 1) {
                        self.teamOneGetNewStatement()
                    } else {
                        self.teamTwoGetNewStatement()
                    }
                    
                    delay(1.0) {
                        // print("Transitioning back to Statement View")
                        self.scrollView!.slideInFromRight(0.5)
                        self.scrollView!.contentOffset = CGPointMake(self.view.frame.width, 0)
                        self.FictionVc.hideAnswer()
                        
                        // Re-enable scroll and pause button
                        self.scrollView!.scrollEnabled = true
                        self.pauseButton.enabled = true
                        
                        // Restart clock for next statement
                        self.StatementVc.rotateClockHand(self.timeLimit)
                    }
                }
            } else {
                // Malformed answer to statement (error in database?)
                print("database error 1? statement no. \(self.statementNo)")
                gameover()
            }
            
        // Fact choice
        case 2:
            // Disable scroll and pause (otherwise weird stuff happens)
            self.scrollView!.scrollEnabled = false
            self.pauseButton.enabled = false
            
            // Timeout occured, slide to make transition nice
            if finished {
                self.scrollView!.slideInFromRight(0.5)
            }
            
            self.scrollView!.contentOffset = CGPointMake(self.view.frame.width*2, 0)
            // Answered correctly
            if self.answer == "T" {
                self.FactVc.responseString = "Correct!"
                self.FactVc.answerString = "Answer: Fact"
                self.playerScore += 1
                updateScores()
                self.correctSound?.play()
            }
            // Answered incorrectly
            else {
                self.FactVc.responseString = "Wrong!"
                self.FactVc.answerString = "Answer: Fiction"
                self.playerHearts -= 1
                updateHearts()
                self.wrongSound?.play()
            }
            self.FactVc.revealAnswer()
            
            // Update labels and get new statement (if hearts left)
            if self.playerHearts > 0 {
                if(self.teamNum == 0) {
                    self.getNewStatement()
                } else if (self.teamNum == 1) {
                    self.teamOneGetNewStatement()
                } else {
                    self.teamTwoGetNewStatement()
                }
                // Slide transition back to Statement view
                delay(1.0) {
                    // print("Transitioning back to Statement View")
                    self.scrollView!.slideInFromLeft(0.5)
                    self.scrollView!.contentOffset = CGPointMake(self.view.frame.width, 0)
                    self.FactVc.hideAnswer()
                    
                    // Re-enable scroll and pause button
                    self.scrollView!.scrollEnabled = true
                    self.pauseButton.enabled = true
                    
                    // Restart clock for next statement
                    self.StatementVc.rotateClockHand(self.timeLimit)
                }
            }
        
        // Something went wrong...
        default:
            print("database error 2? statement no. \(self.statementNo)")
            gameover()
        }
        
        // Decrease time after player reaches point threshold
        if (self.playerScore > self.timeDecreaseThresh) && (self.playerScore % self.timeDecreaseIncrement == 0) && (self.timeLimit > self.minTime) {
            self.timeLimit -= 1
            print("Player score \(self.playerScore). Decreasing time limit to \(self.timeLimit).")
        }
    }
    
    // **************************************************************************
    // Helper/Game Functions
    // **************************************************************************
    
    // Find out what subview the scrollview is currently looking at
    func getPageIndex() -> Int {
        let pageIndex : Int
        // xCoord: represents the coordinate of the top left corner of the screen
        // For our purposes, ranges from 0 - 2 (see following diagram)
        // ------------------------------------
        // |0 fiction |1| statement |2| fact  |
        // ------------------------------------
        let xCoord = scrollView.contentOffset.x / scrollView.frame.size.width
        if xCoord >= 0.0 && xCoord < 0.5 {
            pageIndex = 0
        } else if xCoord >= 0.5 && xCoord < 1.5 {
            pageIndex = 1
        } else {
            pageIndex = 2
        }
        return pageIndex
    }
    
    // Update scores on Fact and Fiction subviews
    func updateScores() {
        FictionVc.updateScore(self.playerScore)
        FactVc.updateScore(self.playerScore)
    }
    
    // Get a new statement for the statement subview
    func getNewStatement() {
        // Check if any statements not yet seen
        
        // Choose random statement from unseen list
        let rand = Int(arc4random_uniform(UInt32(self.unseenStatements.count)))
        self.statementNo = self.unseenStatements[rand]
        print("Getting statement \(self.statementNo)")
        StatementVc.updateLabels(self.statementNo)
        
        // Add statement to seen list (if not already there)
        if self.seenStatements.contains(self.statementNo) == false {
            self.seenStatements.append(self.statementNo)
            rootRef.child("\(self.statementNo)/statement").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.statementList[self.statementNo] = snap.value?.description
            }
            rootRef.child("\(self.statementNo)/explanation").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.explanationList[self.statementNo] = snap.value?.description
            }
            rootRef.child("\(self.statementNo)/answer").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.answer = (snap.value?.description)!
                self.answerList[self.statementNo] = (self.answer == "T") ? "Fact" : "Fiction"
            }
            rootRef.child("\(self.statementNo)/source").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.sourceList[self.statementNo] = snap.value?.description
            }
        }
        
        // Remove statement we just used from unseen list
        self.unseenStatements.removeAtIndex(rand)
        
        print("Update seen statments list: \(self.seenStatements)")
    }
    
    func teamOneGetNewStatement() {
        // Check if any statements not yet seen
        
        // Choose random statement from unseen list
        let rand = Int(arc4random_uniform(UInt32(self.teamOneUnseenStatements.count)))
        self.statementNo = self.teamOneUnseenStatements[rand]
        print("Getting statement \(self.statementNo)")
        StatementVc.updateLabels(self.statementNo)
        
        // Add statement to seen list (if not already there)
        if self.teamOneSeenStatements.contains(self.statementNo) == false {
            self.teamOneSeenStatements.append(self.statementNo)
            rootRef.child("\(self.statementNo)/statement").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.teamOneStatementList[self.statementNo] = snap.value?.description
            }
            rootRef.child("\(self.statementNo)/explanation").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.teamOneExplanationList[self.statementNo] = snap.value?.description
            }
            rootRef.child("\(self.statementNo)/answer").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.answer = (snap.value?.description)!
                self.teamOneAnswerList[self.statementNo] = (self.answer == "T") ? "Fact" : "Fiction"
            }
            rootRef.child("\(self.statementNo)/source").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.teamOneSourceList[self.statementNo] = snap.value?.description
            }
        }
        
        // Remove statement we just used from unseen list
        self.teamOneUnseenStatements.removeAtIndex(rand)
        
        print("Update seen statments list: \(self.teamOneSeenStatements)")
    }
    
    func teamTwoGetNewStatement() {
        // Check if any statements not yet seen
        
        // Choose random statement from unseen list
        let rand = Int(arc4random_uniform(UInt32(self.teamTwoUnseenStatements.count)))
        self.statementNo = self.teamTwoUnseenStatements[rand]
        print("Getting statement \(self.statementNo)")
        StatementVc.updateLabels(self.statementNo)
        
        // Add statement to seen list (if not already there)
        if self.teamTwoSeenStatements.contains(self.statementNo) == false {
            self.teamTwoSeenStatements.append(self.statementNo)
            rootRef.child("\(self.statementNo)/statement").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.teamTwoStatementList[self.statementNo] = snap.value?.description
            }
            rootRef.child("\(self.statementNo)/explanation").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.teamTwoExplanationList[self.statementNo] = snap.value?.description
            }
            rootRef.child("\(self.statementNo)/answer").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.answer = (snap.value?.description)!
                self.teamTwoAnswerList[self.statementNo] = (self.answer == "T") ? "Fact" : "Fiction"
            }
            rootRef.child("\(self.statementNo)/source").observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.teamTwoSourceList[self.statementNo] = snap.value?.description
            }
        }
        
        // Remove statement we just used from unseen list
        self.teamTwoUnseenStatements.removeAtIndex(rand)
        
        print("Update seen statments list: \(self.teamTwoSeenStatements)")
    }

    // Update hearts on the main scrollview screen
    func updateHearts() {
        // Update heart label
        switch self.playerHearts {
        case 5:
            self.heartLabel.text = "♥ ♥ ♥ ♥ ♥"
        case 4:
            self.heartLabel.text = "♥ ♥ ♥ ♥"
        case 3:
            self.heartLabel.text = "♥ ♥ ♥"
        case 2:
            self.heartLabel.text = "♥ ♥"
        case 1:
            self.heartLabel.text = "♥"
        default:    // Zero or invalid hearts = gameover
            self.heartLabel.text = ""
            if (self.teamNum == 0) {
                gameover()
            } else {
                
                if self.teamNum == 1 {
                    self.teamOneScore = self.playerScore
                    print("team no. 1 ended: \(self.teamOneScore)")
                } else {
                    self.teamTwoScore = self.playerScore
                }
                
                let defaults = NSUserDefaults.standardUserDefaults()
                let mhs = defaults.integerForKey("multiHighScore")
                
                if self.playerScore > mhs {
                    defaults.setInteger(self.playerScore, forKey: "multiHighScore")
                    print("changed multi high score: \(self.playerScore)")
                }
                
                if (self.teamNum == 2) {
                    nextRound()
                } else {
                    nextTeam()
                }
            }
        }
    }
    
    func nextTeam() -> Void {
        print("next team")
        delay(1.0) { self.performSegueWithIdentifier("nextTeamSegue", sender: self) }
    }
    
    func nextRound() -> Void {
        print("next round")
        delay(1.0) { self.performSegueWithIdentifier("endRoundSegue", sender: self) }
    }
    
    // Go to gameover screen and present final score
    func gameover() {
        print("Game Over")
        delay(1.0) { self.performSegueWithIdentifier("gameoverSegue", sender: self) }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if (segue.identifier == "pauseSegue") {
            let pauseVc = segue.destinationViewController as! PauseViewController
            pauseVc.playerScore = self.playerScore
            pauseVc.QuestionContainerVc = self
            pauseVc.roundNum = self.roundNum
            pauseVc.teamNum = self.teamNum
            self.paused = true
        }
        if (segue.identifier == "gameoverSegue") {
            let gameoverVc = segue.destinationViewController as! GameOverViewController
            
            gameoverVc.finalScore = self.playerScore
            gameoverVc.seenStatements = self.seenStatements
            gameoverVc.statementList = self.statementList
            gameoverVc.explanationList = self.explanationList
            gameoverVc.answerList = self.answerList
            gameoverVc.sourceList = self.sourceList
        }
        if (segue.identifier == "nextTeamSegue") {
            let teamReadyVc = segue.destinationViewController as! MultiPlayerTeamReadyViewController
            if(self.teamNum == 1) {
                teamReadyVc.teamNum = 2
            } else {
                teamReadyVc.teamNum = 1
            }
            teamReadyVc.num_entries = self.num_entries
            teamReadyVc.roundNum = self.roundNum
            teamReadyVc.timePerQ = Int(self.timeLimit)
            teamReadyVc.numRounds = self.numRounds
            
            teamReadyVc.teamOneScore = self.teamOneScore
            teamReadyVc.teamOneRounds = self.teamOneRounds
            teamReadyVc.teamOneSeenStatements = self.teamOneSeenStatements
            teamReadyVc.teamOneUnseenStatements = self.teamOneUnseenStatements
            teamReadyVc.teamOneStatementList = self.teamOneStatementList
            teamReadyVc.teamOneExplanationList = self.teamOneExplanationList
            teamReadyVc.teamOneAnswerList = self.teamOneAnswerList
            teamReadyVc.teamOneSourceList = self.teamOneSourceList

            teamReadyVc.teamTwoScore = self.teamTwoScore
            teamReadyVc.teamTwoRounds = self.teamTwoRounds
            teamReadyVc.teamTwoSeenStatements = self.teamTwoSeenStatements
            teamReadyVc.teamTwoUnseenStatements = self.teamTwoUnseenStatements
            teamReadyVc.teamTwoStatementList = self.teamTwoStatementList
            teamReadyVc.teamTwoExplanationList = self.teamTwoExplanationList
            teamReadyVc.teamTwoAnswerList = self.teamTwoAnswerList
            teamReadyVc.teamTwoSourceList = self.teamTwoSourceList

        }
        if (segue.identifier == "endRoundSegue") {
            let endRoundVc = segue.destinationViewController as! EndRoundViewController
            endRoundVc.roundNum = self.roundNum
            endRoundVc.timePerQ = Int(self.timeLimit)
            endRoundVc.numRounds = self.numRounds
            endRoundVc.num_entries = self.num_entries
            
            endRoundVc.teamOneScore = self.teamOneScore
            endRoundVc.teamOneRounds = self.teamOneRounds
            endRoundVc.teamOneSeenStatements = self.teamOneSeenStatements
            endRoundVc.teamOneUnseenStatements = self.teamOneUnseenStatements
            endRoundVc.teamOneStatementList = self.teamOneStatementList
            endRoundVc.teamOneExplanationList = self.teamOneExplanationList
            endRoundVc.teamOneAnswerList = self.teamOneAnswerList
            endRoundVc.teamOneSourceList = self.teamOneSourceList
            
            endRoundVc.teamTwoScore = self.teamTwoScore
            endRoundVc.teamTwoRounds = self.teamTwoRounds
            endRoundVc.teamTwoSeenStatements = self.teamTwoSeenStatements
            endRoundVc.teamTwoUnseenStatements = self.teamTwoUnseenStatements
            endRoundVc.teamTwoStatementList = self.teamTwoStatementList
            endRoundVc.teamTwoExplanationList = self.teamTwoExplanationList
            endRoundVc.teamTwoAnswerList = self.teamTwoAnswerList
            endRoundVc.teamTwoSourceList = self.teamTwoSourceList

            print("team 1: \(self.teamOneScore)")
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
