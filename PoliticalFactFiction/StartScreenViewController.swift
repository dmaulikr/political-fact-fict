//
//  StartScreenViewController.swift
//  PoliticalFactFiction
//
//  Created by Thang Nguyen on 6/25/16.
//  Copyright © 2016 jpwm. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class StartScreenViewController: UIViewController {
    
    let rootRef = FIRDatabase.database().reference()
    

    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    var tapSound : AVAudioPlayer?

    var highscore: Int = 0
    var num_entries : Int = 500
    
    @IBAction func pressSingleButton() {
        self.tapSound?.play()
    }
    @IBAction func pressMultiButton() {
        self.tapSound?.play()
    }
    @IBAction func pressHelpButton() {
        self.tapSound?.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singleButton.layer.shadowOpacity = 0.9
        singleButton.layer.shadowRadius = 2.0
        singleButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        singleButton.layer.borderWidth = 2.0
        multiButton.layer.shadowOpacity = 0.9
        multiButton.layer.shadowRadius = 2.0
        multiButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        multiButton.layer.borderWidth = 2.0
        
        // Load number of entries in the database
        rootRef.child("num-entries").observeEventType(.Value) { (snap: FIRDataSnapshot) in
            if let en = snap.value?.description {
                self.num_entries = Int(en)!
            }
        }
        
        // Setup button tap sound
        if let tapSound = setupAudioPlayerWithFile("tap-warm", type: "wav") {
            self.tapSound = tapSound
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if (segue.identifier == "singleSegue") {
            let singleVc = segue.destinationViewController as! SinglePlayerViewController
            print("Number of entries is \(self.num_entries)")
            singleVc.num_entries = self.num_entries
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

