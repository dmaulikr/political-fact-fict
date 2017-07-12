//
//  Utilities.swift
//  PoliticalFactFiction
//
//  Created by Wesley Minner on 7/17/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import AVFoundation

func delay(time: Double = 1.0, closure: () -> () ) {
    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(time * Double(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue()) {
        closure()
    }
}

func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer? {
    let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
    let url = NSURL.fileURLWithPath(path!)
    var audioPlayer: AVAudioPlayer?
    
    do {
        try audioPlayer = AVAudioPlayer(contentsOfURL: url)
    } catch {
        print("Player not available")
    }
    
    return audioPlayer
}

extension UIView {
    
    func fadeInOut(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create animation
        let transition = CATransition()
        
        // Set callback delegate to completionDelegate (if provided)
        if let delegate: AnyObject = completionDelegate {
            transition.delegate = delegate as? CAAnimationDelegate
        }
        
        // Customize animation properties
        transition.type = kCATransitionFade
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        // Add animation to View's layer
        self.layer.addAnimation(transition, forKey: "fadeInOutTransition")

    }
    
    func slideInFromLeft(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create animation
        let transition = CATransition()
        
        // Set callback delegate to completionDelegate (if provided)
        if let delegate: AnyObject = completionDelegate {
            transition.delegate = delegate as? CAAnimationDelegate
        }
        
        // Customize animation properties
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.fillMode = kCAFillModeRemoved
        
        // Add animation to View's layer
        self.layer.addAnimation(transition, forKey: "slideInFromLeftTransition")
    }
    
    func slideInFromRight(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create animation
        let transition = CATransition()
        
        // Set callback delegate to completionDelegate (if provided)
        if let delegate: AnyObject = completionDelegate {
            transition.delegate = delegate as? CAAnimationDelegate
        }
        
        // Customize animation properties
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.fillMode = kCAFillModeRemoved
        
        // Add animation to ScrollView's layer
        self.layer.addAnimation(transition, forKey: "slideInFromRightTransition")
    }
}
