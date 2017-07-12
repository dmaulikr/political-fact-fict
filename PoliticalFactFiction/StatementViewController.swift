//
//  StatementViewController.swift
//  PoliticalFactFiction
//
//  Created by Wesley Minner on 7/12/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

// Statement View

import UIKit
import Firebase

class StatementViewController: UIViewController {
    
    @IBOutlet weak var statementText: UITextView!
    @IBOutlet weak var clockView: UIView!
    @IBOutlet weak var clockHand: UIImageView!
    
    let rootRef = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func rotateClockHand(duration: Double, delay: Double = 0.3, resume: Double = 0.0) {
        // Record start time
        if let QuestionContainerVc = self.parentViewController as? SP_QuestionContainer_ViewController {
            QuestionContainerVc.startTime = CACurrentMediaTime() + delay
        }
        print("Start time recorded at \(self.clockHand.layer.timeOffset)")
        
        // Calculate and go to start position (if resuming the animation from pause screen)
        let resume_pos = resume/duration * M_PI * 2.0
        self.clockHand.transform = CGAffineTransformRotate(self.clockHand.transform, CGFloat(resume_pos))
        
        // Perform the rest of the animation
        let remaining_rot = 2.0 * M_PI - resume_pos
        print("remaining_rotation is \(remaining_rot*180/M_PI) degrees")
        UIView.animateWithDuration((duration-resume)/2.0, delay: delay, options: [.CurveLinear], animations: {
            self.clockHand.transform = CGAffineTransformRotate(self.clockHand.transform, CGFloat(remaining_rot/2.0))
            }, completion: nil)
        UIView.animateWithDuration((duration-resume)/2.0, delay: (duration-resume)/2.0 + delay, options: [.CurveLinear], animations: {
            self.clockHand.transform = CGAffineTransformRotate(self.clockHand.transform, CGFloat(remaining_rot/2.0))
            }, completion: { finished in
                
                if finished {
                    print("Clock rotation finished")
                } else {
                    print("Clock rotation didn't finish")
                }
                
                if let QuestionContainerVc = self.parentViewController as? SP_QuestionContainer_ViewController {
                    // If animation completed, not due to pausing
                    if !QuestionContainerVc.paused {
                        QuestionContainerVc.runningTime = 0
                        QuestionContainerVc.animationComplete(finished)
                    }
                }
        })
    }
    
    func resetClockHand() {
        self.clockHand.layer.removeAllAnimations()
    }
    
    func updateLabels(statementNo: Int) {
        rootRef.child("\(statementNo)").child("statement").observeEventType(.Value) { (snap: FIRDataSnapshot) in
            self.statementText.text = snap.value?.description
        }
    }
    
    @IBAction func touchFactButton() {
        // Call touch fact button routine on question VC
        if let QuestionContainerVc = self.parentViewController as? SP_QuestionContainer_ViewController {
            QuestionContainerVc.touchFactButton()
        }
    }
    
    @IBAction func touchFictionButton() {
        // Call touch fact button routine on question VC
        if let QuestionContainerVc = self.parentViewController as? SP_QuestionContainer_ViewController {
            QuestionContainerVc.touchFictionButton()
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
