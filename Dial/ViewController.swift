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
//        let ns = TimeInterval(Calendar.current.component(.nanosecond, from: currentDate))
//        let fs = seconds+ns
        let df = DateFormatter()
        df.dateFormat = "SSSS"
        let fs = seconds+Double("0."+df.string(from: currentDate))!
        (view as! DialView).update(fs,seconds)
    }

}


class DialView:UIView{
    
    var drawToPoint:CGPoint! = CGPoint(x: 0, y: 0)
    var currentSecond:TimeInterval! = 0
    
    let animationLine = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black
        let point = CAShapeLayer()
        point.frame = CGRect(origin: .zero, size: CGSize(width: 5, height: 5))
        point.path = UIBezierPath(ovalIn: point.frame).cgPath
        point.fillColor = UIColor.white.cgColor
        point.position = self.center
        self.layer.addSublayer(point)
        
        let newframe = CGRect(origin: bounds.origin, size: CGSize(width: 20, height:  bounds.height / 3 * 4))
        animationLine.frame = newframe // bounds
        animationLine.borderWidth = 1.0
        animationLine.borderColor = UIColor.red.cgColor
        animationLine.position = center
        animationLine.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        print(center,animationLine.position)
        let path = UIBezierPath()
        path.move(to: animationLine.position)
        path.addLine(to: CGPoint(x: center.x, y: -30))
        animationLine.bounds = path.cgPath.boundingBox
        animationLine.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        //animationLine.actions = newActions;
        animationLine.path = path.cgPath
        animationLine.lineWidth = 2.0
        animationLine.opacity = 0
        animationLine.strokeColor = UIColor.white.cgColor
        self.layer.addSublayer(animationLine)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ animationTimeseconds:TimeInterval,_ seconds:TimeInterval){

        let lineangle = CGFloat(GLKMathDegreesToRadians((360.0 / 60.0) * Float(animationTimeseconds)))
        
        let angle = CGFloat(GLKMathDegreesToRadians((360.0 / 60.0) * Float(animationTimeseconds) - 90))
        
        if(seconds != currentSecond){
            currentSecond = seconds
            //print("second updated",currentSecond)
            
            
        
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1.0
            animation.toValue = 0.0
            animation.beginTime = 0.0
            animation.duration = 0.5
            animation.fillMode = kCAFillModeForwards
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            animationLine.setAffineTransform(CGAffineTransform(rotationAngle: lineangle))
            animationLine.add(animation, forKey: nil)
            CATransaction.commit()
            
        }
        
    
        let radius:CGFloat = CGFloat(self.bounds.height/2) / 2 * 3
        
        let x = CGFloat(center.x + radius * cos(angle) )
        let y = CGFloat(center.y + radius * sin(angle) )
        
        drawToPoint = CGPoint(x: x, y: y)
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        context?.setLineWidth(1.0)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.beginPath()
        context?.move(to: self.center)
        context?.addLine(to: drawToPoint)
        context?.strokePath()
    }
    
}
