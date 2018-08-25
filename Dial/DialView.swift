//
//  DialView.swift
//  Dial
//
//  Created by Joss Manger on 8/24/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import UIKit
import GLKit

class DialView:UIView{
    
    private var drawToPoint:CGPoint! = CGPoint(x: 0, y: 0)
    private var currentSecond:TimeInterval = 0
    private var minutes:TimeInterval = 0
    private var remainingMinutes:Int = 0
    private var arcAngle:CGFloat = 0.0
    
    let animationLine = CAShapeLayer()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.black
        
        //create shape layer for spot in center
        let point = CAShapeLayer()
        point.frame = CGRect(origin: .zero, size: CGSize(width: 5, height: 5))
        point.path = UIBezierPath(ovalIn: point.frame).cgPath
        point.fillColor = UIColor.white.cgColor
        point.position = self.center
        self.layer.addSublayer(point)
        
        // setup CAShapeLayer
        animationLine.position = center
        animationLine.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //create pulsing hand that will be animated in and out later
        
        //draw path
        let path = UIBezierPath()
        path.move(to: animationLine.position)
        path.addLine(to: CGPoint(x: center.x, y: -30))
        
        // make bounding box of shape layer the box of the path.
        animationLine.bounds = path.cgPath.boundingBox
        
        //set anchorpoint around which transformation will occur
        animationLine.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        //assign path to shape layer
        animationLine.path = path.cgPath
        animationLine.lineWidth = 2.0
        animationLine.opacity = 0
        animationLine.strokeColor = UIColor.white.cgColor
        self.layer.addSublayer(animationLine)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //receive redraw event with time values
    
    func update(_ animationTimeseconds:TimeInterval,_ seconds:TimeInterval,_ minutes:TimeInterval){
        
        //angle values
        let lineangle = CGFloat(GLKMathDegreesToRadians((360.0 / 60.0) * Float(animationTimeseconds)))
        let angle = CGFloat(GLKMathDegreesToRadians((360.0 / 60.0) * Float(animationTimeseconds) - 90))
        
        arcAngle = angle
        
        //update variables only when the values explicitly change
        if(minutes != self.minutes){
            self.minutes = minutes
            remainingMinutes = 60 - Int(minutes)
            print(remainingMinutes)
        }
        
        if(seconds != currentSecond){
            currentSecond = seconds

            //whole number seconds has updated, trigger second hand animation
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
        
        //calcualte drawTo point (trig)
        let radius:CGFloat = CGFloat(self.bounds.height/2) / 2 * 3
        
        let x = CGFloat(center.x + radius * cos(angle) )
        let y = CGFloat(center.y + radius * sin(angle) )
        
        drawToPoint = CGPoint(x: x, y: y)
        
        //trigger redraw
       self.setNeedsDisplay()
        
    }
    
    override func draw(_ rect: CGRect) {
        
        //get context
        let context = UIGraphicsGetCurrentContext()
        
        //create circlepath for current minute
        let circlePath = UIBezierPath(arcCenter: self.center, radius: 10, startAngle: CGFloat(GLKMathDegreesToRadians(-90.0)), endAngle: arcAngle, clockwise: false)
        
        //draw the constantly updating second hands
        context?.setLineWidth(1.0)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.beginPath()
        context?.move(to: self.center)
        context?.addLine(to: drawToPoint)
        context?.strokePath()
        context?.setFillColor(UIColor.clear.cgColor)
        circlePath.stroke()
        
        //create concentric circlepaths for remaining minutes
        //pretty unnecessarily intensive...
        for remainingMinute in 0...remainingMinutes{
            let radius = CGFloat(remainingMinute * 10 + 20)
            let circlePath = UIBezierPath(arcCenter: self.center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            circlePath.stroke()
        }
        
    }
    
}
