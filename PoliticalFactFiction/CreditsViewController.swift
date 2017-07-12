//
//  CreditsViewController.swift
//  PoliticalFactFiction
//
//  Created by Wesley Minner on 9/17/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import AVFoundation

class CreditsViewController: UIViewController {

    @IBOutlet weak var okButton: UIButton!
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
    
    @IBAction func popView() {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
