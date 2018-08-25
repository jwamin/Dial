//
//  ViewController.swift
//  Dial
//
//  Created by Joss Manger on 8/16/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import UIKit
import GLKit

class ResetButton : UIButton{
    
    override var isHighlighted: Bool{
        didSet{
            if isHighlighted {
                self.backgroundColor = UIColor.white
            } else {
                self.backgroundColor = UIColor.black
            }
        }
    }

}


class ViewController: UIViewController {

    var link:CADisplayLink!
    
    let maxZoom:CGFloat = 2.0
    let minZoom:CGFloat = 0.6
    
    var dialView:DialView!
    
    var resetButton:ResetButton!
    var bottomConstraint:NSLayoutConstraint!
    
    var didMove:Bool = false{
        didSet{
            if(didMove != oldValue && didMove == true){
                showResetButton()
            }
        }
    }
    
    
    private var cumulativeScale:CGFloat = 1.0
    
    let tempConstantForLayoutScaling:CGFloat = 700.0
    
    override var preferredStatusBarStyle:UIStatusBarStyle{
            return .lightContent
    }
    
    override func loadView() {
        self.view = UIView()
        dialView = DialView(frame: UIScreen.main.bounds);
        self.view.addSubview(dialView)
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
        
        resetButton = ResetButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.layer.masksToBounds = false
        resetButton.clipsToBounds = true
        resetButton.layer.cornerRadius = resetButton.frame.size.height / 2
        resetButton.layer.borderColor = UIColor.white.cgColor
        resetButton.layer.borderWidth = 2.0
        resetButton.isEnabled = false
        resetButton.addTarget(self, action: #selector(resetView), for: .touchUpInside)
        self.view.addSubview(resetButton)
        
        //Setup Constraints
        NSLayoutConstraint(item: resetButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80).isActive = true
        NSLayoutConstraint(item: resetButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80).isActive = true
        
        bottomConstraint = NSLayoutConstraint(item: resetButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottomMargin, multiplier: 1.0, constant: 160)
        bottomConstraint.isActive = true
        
        NSLayoutConstraint(item: resetButton, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .rightMargin, multiplier: 1.0, constant: -30).isActive = true
        

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
   @objc func resetView(){
    
        if(didMove){
            self.bottomConstraint.constant = 160
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 10, initialSpringVelocity: 20, options: [.beginFromCurrentState], animations: {
               
                self.dialView.center = CGPoint(x: self.view.center.x,
                                          y: self.view.center.y)
                
                self.dialView.transform = .identity
                
                self.view.layoutIfNeeded()
                
            }) { (complete) in
                if(complete){
                    print("reset complete")
                    self.didMove = false
                    self.resetButton.isEnabled = false
                    self.cumulativeScale = 1.0
                }
            }
            
        }

    }
    
    func showResetButton(){
        
        print("showing reset button")
         self.bottomConstraint.constant = -30
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 10, initialSpringVelocity: 20, options: [.beginFromCurrentState], animations: {
           
            self.view.layoutIfNeeded()
        }) { (complete) in
            if(complete){
                print("complete")
                self.resetButton.isEnabled = true
            }
        }
        
        
        
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
        dialView.update(fs,seconds,minutes)
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
                dialView.transform = dialView.transform.scaledBy(x: gestureRecognizer.scale,
                                                                 y: gestureRecognizer.scale);
                didMove = true
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
                    dialView.transform = dialView.transform.scaledBy(x: gestureRecognizer.scale,
                                                                     y: gestureRecognizer.scale);
                } else {
                    print("out of range",nextScale,cumulativeScale,maxZoom,minZoom)
                }
            }
        }
        
        //gestureRecognizer.scale = 1;
    }
    
    @objc func pan(gestureRecognizer: UIPanGestureRecognizer) {
         let animView = dialView
        
        let translation = gestureRecognizer.translation(in: view)
        
        dialView.center = CGPoint(x: dialView.center.x + translation.x,
                                             y: dialView.center.y + translation.y)
        didMove = true
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
        
    }
    
}
    


