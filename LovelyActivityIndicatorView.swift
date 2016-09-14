//
//  LovelyActivityIndicatorView.swift
//  LovelyActivityIndicatorView
//
//  Created by Evan Bacon on 09/14/2016.
//  Copyright (c) 2016 bacon brix. All rights reserved.
//

import UIKit



extension UIView {
    /// Just don't tag any other views as `6969`
    func startLoading(style:LovelyActivityIndicatorViewStyle = .Large) {
        
        guard self.viewWithTag(6969) == nil else { return }

        let indicator = LovelyActivityIndicatorView(style: style)
        indicator.center = self.center
        indicator.tag = 6969
        addSubview(indicator)
        indicator.startAnimating()
    }
    
    var loading:Bool! {
        get {
            return (self.viewWithTag(6969) != nil)
        }
    }
    
    func stopLoading() {
        guard let loader = self.viewWithTag(6969) as? LovelyActivityIndicatorView else { return }
        loader.stopAnimating({
            _ in
            loader.removeFromSuperview()
        })
    }
}

public extension UIBezierPath  {
    
    func getHearts(originalRect: CGRect, scale: Double) -> UIBezierPath {
        
        //Scaling will take bounds from the originalRect passed
        let scaledWidth = (originalRect.size.width * CGFloat(scale))
        let scaledXValue = ((originalRect.size.width) - scaledWidth) / 2
        let scaledHeight = (originalRect.size.height * CGFloat(scale))
        let scaledYValue = ((originalRect.size.height) - scaledHeight) / 2
        
        let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
        self.moveToPoint(CGPointMake(originalRect.size.width/2, scaledRect.origin.y + scaledRect.size.height))
        
        self.addCurveToPoint(CGPointMake(scaledRect.origin.x, scaledRect.origin.y + (scaledRect.size.height/4)),
                             controlPoint1:CGPointMake(scaledRect.origin.x + (scaledRect.size.width/2), scaledRect.origin.y + (scaledRect.size.height*3/4)) ,
                             controlPoint2: CGPointMake(scaledRect.origin.x, scaledRect.origin.y + (scaledRect.size.height/2)) )
        
        self.addArcWithCenter(CGPointMake( scaledRect.origin.x + (scaledRect.size.width/4),scaledRect.origin.y + (scaledRect.size.height/4)),
                              radius: (scaledRect.size.width/4),
                              startAngle: CGFloat(M_PI),
                              endAngle: 0,
                              clockwise: true)
        
        self.addArcWithCenter(CGPointMake( scaledRect.origin.x + (scaledRect.size.width * 3/4),scaledRect.origin.y + (scaledRect.size.height/4)),
                              radius: (scaledRect.size.width/4),
                              startAngle: CGFloat(M_PI),
                              endAngle: 0,
                              clockwise: true)
        
        self.addCurveToPoint(CGPointMake(originalRect.size.width/2, scaledRect.origin.y + scaledRect.size.height),
                             controlPoint1: CGPointMake(scaledRect.origin.x + scaledRect.size.width, scaledRect.origin.y + (scaledRect.size.height/2)),
                             controlPoint2: CGPointMake(scaledRect.origin.x + (scaledRect.size.width/2), scaledRect.origin.y + (scaledRect.size.height*3/4)) )
        self.closePath()
        return self
    }
}

enum LovelyActivityIndicatorViewStyle: Int {
    case Small = 0, Default, Large

    var size: CGFloat {
        let sizes: [CGFloat] = [20.0, 30.0, 60.0]
        return sizes[rawValue]
    }

    var lineWidth: CGFloat {
        let widths: [CGFloat] = [2.0, 4.0, 8.0]
        return widths[rawValue]
    }

    var duration: CGFloat {
        let durations: [CGFloat] = [0.8, 0.8, 1.0]
        return durations[rawValue]
    }
}

class LovelyActivityIndicatorView: UIView {

    // MARK: - Properties

    let style: LovelyActivityIndicatorViewStyle
    let infinity: Float = 1.0/0.0
    var contentView: UIView!
    var shapeLayer: CAShapeLayer!
    var isAnimating = false
    var currentAnimation = 0
    var timer: NSTimer!

    // MARK: - Overrides

    var colors: [CGColor]!
    var duration: Double!
    var hidesWhenStopped = true

    // MARK: - Initializers

    init(style: LovelyActivityIndicatorViewStyle) {
        self.style = style
        super.init(frame: CGRectMake(0, 0, style.size, style.size))

        let blueColor = UIColor(red:0.145, green:0.380, blue:0.482, alpha: 1).CGColor
        let redColor = UIColor(red:0.753, green:0.224, blue:0.169, alpha: 1).CGColor
        let greenColor = UIColor(red:0.004, green:0.596, blue:0.459, alpha: 1).CGColor
        colors = [blueColor, redColor, greenColor]

        duration = Double(style.duration)

        contentView = UIView(frame: bounds)
        addSubview(contentView)

        let radius: CGFloat = style.size / 2.0
        shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.lineWidth = style.lineWidth
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.path = UIBezierPath().getHearts(CGRectMake(0, 0, 2.0 * radius, 2.0 * radius), scale: 1).CGPath
        shapeLayer.lineCap = kCALineJoinRound;
        shapeLayer.hidden = true;
        contentView.layer.insertSublayer(shapeLayer, atIndex: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Mathods

    func startAnimating() {
        if isAnimating { return }
        isAnimating = true

        let inAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        inAnimation.duration = duration
        inAnimation.values = [0, 1]

        let outAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
        outAnimation.duration = duration
        outAnimation.values = [0, 0.8, 1]
        outAnimation.beginTime = duration / 1.5;

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [inAnimation, outAnimation]
        groupAnimation.duration = duration + outAnimation.beginTime;
        groupAnimation.repeatCount = infinity;

        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnim.fromValue = 0
        rotationAnim.toValue = M_PI * 2
        rotationAnim.duration = duration * 1.5
        rotationAnim.repeatCount = infinity

        shapeLayer.strokeColor = colors.first!
//        shapeLayer.addAnimation(rotationAnim, forKey: "rotation.z")
        shapeLayer.addAnimation(groupAnimation, forKey: nil)

        timer = NSTimer.scheduledTimerWithTimeInterval(duration + outAnimation.beginTime, target: self, selector: "changeStrokeColor", userInfo: nil, repeats: true)
        shapeLayer.hidden = false
    }

    func changeStrokeColor() {
        currentAnimation += 1
        shapeLayer.strokeColor = colors[currentAnimation % colors.count]
    }

    func stopAnimating(completion:() -> Void = {_ in}) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            // Nice fade and ride
            self.contentView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            self.contentView.alpha = 0.0;
            }) { (finished) -> Void in
                self.isAnimating = false
                self.currentAnimation = 0
                self.timer.invalidate()
                self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                self.contentView.alpha = 1.0;
                self.shapeLayer.hidden = self.hidesWhenStopped;
                self.shapeLayer.removeAllAnimations()
                completion()
        }
    }
}
