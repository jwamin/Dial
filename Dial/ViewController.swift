//
//  ViewController.swift
//  Dial
//
//  Created by Joss Manger on 8/16/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import UIKit
import GLKit

class ViewController: UIViewController {

    var link:CADisplayLink!
    
    override var preferredStatusBarStyle:UIStatusBarStyle{
            return .lightContent
    }
    
    override func loadView() {
        self.view = DialView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.update()
        link = CADisplayLink(target: self, selector: #selector(update))
        link.preferredFramesPerSecond = 60
        link.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
        print(self.view.frame)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func update(){
        let currentDate = Date()
        let seconds = TimeInterval(Calendar.current.component(.second, from: currentDate))
        let minutes = TimeInterval(Calendar.current.component(.minute, from: currentDate))
//        let ns = TimeInterval(Calendar.current.component(.nanosecond, from: currentDate))
//        let fs = seconds+ns
        let df = DateFormatter()
        df.dateFormat = "SSSS"
        let fs = seconds+Double("0."+df.string(from: currentDate))!
        (view as! DialView).update(fs,seconds,minutes)
    }

}
