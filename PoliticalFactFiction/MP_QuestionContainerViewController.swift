//
//  MP_QuestionContainerViewController.swift
//  PoliticalFactFiction
//
//  Created by Jason La on 8/21/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import Firebase

class MP_QuestionContainerViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pauseButton: UIButton!
    
    let rootRef = FIRDatabase.database().reference()
    let subviewList = ["Fiction", "Statement", "Fact"]
    
    var playerScore: Int = 0            // Number of questions player answered correctly
    var playerHearts: Int = 5           // Errors the player can make remaining
    var statementNo: Int = 1            // Number of currently shown statement
    var num_entries: Int = 1            // Number of statements in the database
    var answer = ""                     // Answer to the statement (either 'T' for true/fact or 'F' for false/fiction)
    var timeLimit: Double = 5.0         // Time player has to give an answer
    var seenStatements: [Int] = []      // Contains statements player has received so far (for reference list on the game over screen)
    var unseenStatements: [Int] = []    // Contains statements player has not received so far (to help avoid duplicates when choosing next statement)
    
    var paused: Bool = false
    var startTime: CFTimeInterval = 0.0       // Keeps track of the time at which the statement was started
    var runningTime: CFTimeInterval = 0.0     // Keeps track of total time running for each statement
    
    var statementList: [Int : String] = [:]
    var explanationList: [Int : String] = [:]
    var answerList: [Int : String] = [:]
    
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
        unseenStatements += 1...self.num_entries
        
        getNewStatement()
        
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.paused {
            self.resumeLayer(self.StatementVc.clockHand.layer)
        }
    }
    
    // **************************************************************************
    // Pause/Resume Functions
    // **************************************************************************
    
    @IBAction func pauseGame(sender: AnyObject) {
        self.pauseLayer(self.StatementVc.clockHand.layer)

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
    func animationComplete(finished: Bool) {
        let pageIndex : Int = getPageIndex()
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
            if self.answer == "F" {
                self.FictionVc.responseString = "Correct!"
                self.FictionVc.answerString = "Answer: Fiction"
                self.playerScore += 1
                self.updateScores()
            }
                // Answered incorrectly
            else {
                self.FictionVc.responseString = "Wrong!"
                self.FictionVc.answerString = "Answer: Fact"
                self.playerHearts -= 1
                self.updateHearts()
            }
            self.FictionVc.revealAnswer()
            
            // Update labels and get new statement (if hearts left)
            if self.playerHearts > 0 {
                self.getNewStatement()
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
                
                // If player not dead, then get a new statement and continue game
                if self.playerHearts > 0 {
                    getNewStatement()
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
                
                // If player not dead, then get a new statement and continue game
                if self.playerHearts > 0 {
                    getNewStatement()
                    
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
            if self.answer == "T" {
                self.FactVc.responseString = "Correct!"
                self.FactVc.answerString = "Answer: Fact"
                self.playerScore += 1
                updateScores()
            }
                // Answered incorrectly
            else {
                self.FactVc.responseString = "Wrong!"
                self.FactVc.answerString = "Answer: Fiction"
                self.playerHearts -= 1
                updateHearts()
            }
            FactVc.revealAnswer()
            
            // Update labels and get new statement (if hearts left)
            if self.playerHearts > 0 {
                getNewStatement()
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
            gameover()
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
        if self.unseenStatements.count == 0 {
            // If so, then reset list to include all statements again
            self.unseenStatements += 1...self.num_entries
        }
        
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
        }
        
        // Remove statement we just used from unseen list
        self.unseenStatements.removeAtIndex(rand)
        
        print("Update seen statments list: \(self.seenStatements)")
    }
    
    // Update hearts on the main scrollview screen
    func updateHearts() {
        // Update heart label
        switch self.playerHearts {
        case 5:
            self.heartLabel.text = "<3 <3 <3 <3 <3"
        case 4:
            self.heartLabel.text = "<3 <3 <3 <3"
        case 3:
            self.heartLabel.text = "<3 <3 <3"
        case 2:
            self.heartLabel.text = "<3 <3"
        case 1:
            self.heartLabel.text = "<3"
        default:    // Zero or invalid hearts = gameover
            self.heartLabel.text = ""
            gameover()
        }
    }
    
    // Go to gameover screen and present final score
    func gameover() {
        print("Game Over")
        delay(1.0) { self.performSegueWithIdentifier("gameoverSegue", sender: self) }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if (segue.identifier == "mPauseSegue") {
            let pauseVc = segue.destinationViewController as! PauseViewController
            pauseVc.playerScore = self.playerScore
            //pauseVc.QuestionContainerVc = self
            self.paused = true
        }
        if (segue.identifier == "gameoverSegue") {
            let gameoverVc = segue.destinationViewController as! GameOverViewController
            gameoverVc.finalScore = self.playerScore
            gameoverVc.seenStatements = self.seenStatements
            gameoverVc.statementList = self.statementList
            gameoverVc.explanationList = self.explanationList
            gameoverVc.answerList = self.answerList
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
