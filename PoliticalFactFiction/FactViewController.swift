//
//  FactViewController.swift
//  PoliticalFactFiction
//
//  Created by Wesley Minner on 7/12/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

// Answer Fact View

import UIKit
import Firebase

class FactViewController: UIViewController {
       
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var labelCollection: UIView!
    
    let rootRef = FIRDatabase.database().reference()
    var responseString = ""
    var answerString = ""
    var scoreString = "Score: 0"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide labels on page until player decides an answer
        self.responseLabel.text = ""
        self.answerLabel.text = ""
        self.scoreLabel.text = ""
    }
    
    func revealAnswer() {
        self.labelCollection.fadeInOut(1.0)
        
        self.responseLabel.text = responseString
        self.answerLabel.text = answerString
        self.scoreLabel.text = scoreString
    }
    
    func hideAnswer() {
        self.responseLabel.text = ""
        self.answerLabel.text = ""
        self.scoreLabel.text = ""
    }
    
    func updateScore(score: Int) {
//        self.scoreLabel.text = "Score: \(score)"
        self.scoreString = "Score: \(score)"
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
