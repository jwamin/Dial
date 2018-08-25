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
    
    let maxZoom:CGFloat = 2.0
    let minZoom:CGFloat = 0.6
    
    private var cumulativeScale:CGFloat = 1.0
    
    let tempConstantForLayoutScaling:CGFloat = 700.0
    
    override var preferredStatusBarStyle:UIStatusBarStyle{
            return .lightContent
    }
    
    override func loadView() {
        self.view = DialView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        link = CADisplayLink(target: self, selector: #selector(update(_:)))
        link.preferredFramesPerSecond = 60
        link.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
        print(self.view.frame)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom(gestureRecognizer:)))
        self.view.addGestureRecognizer(pinchGesture)
        
//        let tapgestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
//        self.view.addGestureRecognizer(tapgestureRecogniser)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(gestureRecognizer:)))
        self.view.addGestureRecognizer(panGesture)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func update(_ link:CADisplayLink){
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

    
//    @objc func tap(tap:UITapGestureRecognizer){
//        print("tap")
//        animView.showLine = !animView.showLine
//    }
    
    @objc func zoom(gestureRecognizer: UIPinchGestureRecognizer) {
        
        if gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            
            // Ensure the cumulative scale is within the set range
            if cumulativeScale > minZoom && cumulativeScale < maxZoom {
                print("within range")
                // Increment the scale
                cumulativeScale *= gestureRecognizer.scale
                
                // Execute the transform
                (view as! DialView).transform = (view as! DialView).transform.scaledBy(x: gestureRecognizer.scale,
                                                                 y: gestureRecognizer.scale);
            } else {
                print("something")
                // If the cumulative scale has extended beyond the range, check
                // to see if the user is attempting to scale it back within range
                let nextScale = cumulativeScale * gestureRecognizer.scale
                
                if cumulativeScale < minZoom && nextScale > minZoom
                    || cumulativeScale > maxZoom && nextScale < maxZoom {
                    print("will apply scale")
                    // If the user is trying to get back in-range, allow the transform
                    cumulativeScale *= gestureRecognizer.scale
                    (view as! DialView).transform = (view as! DialView).transform.scaledBy(x: gestureRecognizer.scale,
                                                                     y: gestureRecognizer.scale);
                } else {
                    print("out of range",nextScale,cumulativeScale,maxZoom,minZoom)
                }
            }
        }
        
        //gestureRecognizer.scale = 1;
    }
    
    @objc func pan(gestureRecognizer: UIPanGestureRecognizer) {
         let animView = (view as! DialView)
        
        let translation = gestureRecognizer.translation(in: view)
        
        (view as! DialView).center = CGPoint(x: (view as! DialView).center.x + translation.x,
                                             y: (view as! DialView).center.y + translation.y)
        
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
        
    }
    
}
    


