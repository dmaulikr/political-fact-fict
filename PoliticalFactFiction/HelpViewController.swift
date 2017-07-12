//
//  HelpViewController.swift
//  PoliticalFactFiction
//
//  Created by Wesley Minner on 7/11/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import AVFoundation

class HelpViewController: UIViewController {

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var creditsButton: UIButton!
    var tapSound : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        okButton.layer.shadowOpacity = 0.9
        okButton.layer.shadowRadius = 2.0
        okButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        okButton.layer.borderWidth = 2.0
        
        // Setup button tap sound
        if let tapSound = setupAudioPlayerWithFile("tap-warm", type: "wav") {
            self.tapSound = tapSound
        }
    }
    
    @IBAction func pressCreditsButton() {
        self.tapSound?.play()
    }
    
    @IBAction func returnToStart() {
        self.tapSound?.play()
        self.navigationController?.popViewControllerAnimated(true)
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
