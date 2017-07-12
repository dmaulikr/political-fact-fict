//
//  GameOverViewController.swift
//  PoliticalFactFiction
//
//  Created by Wesley Minner on 7/16/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class GameOverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let rootRef = FIRDatabase.database().reference()
    
    var finalScore: Int = 0
    var seenStatements: [Int] = []
    
    var tapSound: AVAudioPlayer?
    
    // Cell dictionarys for the table
    var explanationList: [Int: String] = [0: "explanation"]
    var statementList: [Int: String] = [0: "statement"]
    var answerList: [Int: String] = [0: "answer"]
    var sourceList: [Int: String] = [0: "source"]
    
    // Statements that have explanations, so will b/Users/jasonla/political-fact-or-fiction/PoliticalFactFiction/GameOverViewController.swifte included in table
    var includeStatements: [Int] = [0]
    
    // multiplayer
    var teamNum: Int = 0
    
    @IBAction func goBack() {
        self.tapSound?.play()
        self.navigationController!.popViewControllerAnimated(true)
    }
    @IBAction func pressDoneButton() {
        self.tapSound?.play()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get user high score
        let defaults = NSUserDefaults.standardUserDefaults()
        let hs = defaults.integerForKey("userHighScore")
        
        // Overwrite high score if final score is higher
        if teamNum == 0 {
            if hs < self.finalScore {
                defaults.setInteger(self.finalScore, forKey: "userHighScore")
                print("Wrote high score to NSUserDefaults. Old: \(hs), New: \(self.finalScore)")
            }
        }
        
        // Set final score label
        if (teamNum == 0) {
            self.backButton.hidden = true
            self.finalScoreLabel.text = "Final Score: \(self.finalScore)"
        } else {
            self.finalScoreLabel.text = "Team \(self.teamNum)"
        }
        
        // Setup button tap sound
        if let tapSound = setupAudioPlayerWithFile("tap-warm", type: "wav") {
            self.tapSound = tapSound
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seenStatements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let statementNum = seenStatements[indexPath.row]
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomTableViewCell
        let explanation = explanationList[statementNum]
        var answer : String = ""
        
        if (explanation == "") {
            answer = answerList[statementNum]!
        } else {
            answer = "\(answerList[statementNum]!): \(explanationList[statementNum]!)"
        }
        
        cell.statementLabel.text = "\(indexPath.row+1). \(statementList[statementNum]!)"
        cell.answerLabel.text = answer
        cell.referenceLabel.text = "Source: \(sourceList[statementNum]!)"
        
        return cell
    }
    
    // Used to automatically size cell vertical height correct (for word wrap)
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let statementNum = seenStatements[indexPath.row]
        let source = sourceList[statementNum]
        if let url = NSURL(string: source!) {
            UIApplication.sharedApplication().openURL(url)
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
