//
//  DegreeLabel.swift
//  QuoteWeatherApp
//
//  Created by Ryan  Gunn on 9/2/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit

@IBDesignable 
class DegreeLabel: UIView {

    let bgLayer = CAShapeLayer()
    let fgLayer = CAShapeLayer()
    let degreeLabel = UILabel()


    @IBInspectable var bgColor: UIColor = UIColor.grayColor() {
        didSet {
            configure()
        }
    }

    @IBInspectable var fgColor: UIColor = UIColor.blackColor() {
        didSet {
            configure()
        }
    }

    var range = CGFloat(100)
    var curValue = CGFloat(0) {
        didSet {
            animate()
        }
    }
    let margin = CGFloat(10)

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        configure()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
        configure()
    }

    func setup() {

        // Setup bg
        bgLayer.lineWidth = CGFloat(20.0)
        bgLayer.fillColor = UIColor.clearColor().CGColor
        bgLayer.strokeEnd = 1
        layer.addSublayer(bgLayer)


        // Setup fg
        fgLayer.lineWidth = CGFloat(20.0)
        fgLayer.fillColor = UIColor.clearColor().CGColor
        fgLayer.strokeEnd = 0
        layer.addSublayer(fgLayer)

        // Setup percent label
       degreeLabel.font = UIFont(name: "Avenir Next", size: 45)
        degreeLabel.textColor = UIColor.whiteColor()
        degreeLabel.text = "0°"
        degreeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(degreeLabel)

        // Setup caption label
//        captionLabel.font = UIFont(name: "Avenir Next", size: 26)
//        captionLabel.text = "Chapters Read"
//        captionLabel.textColor = UIColor.whiteColor()
//        captionLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
//        addSubview(captionLabel)

        // Setup constraints
        let percentLabelCenterX = NSLayoutConstraint(item: degreeLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
        let percentLabelCenterY = NSLayoutConstraint(item: degreeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: -margin)
        NSLayoutConstraint.activateConstraints([percentLabelCenterX, percentLabelCenterY])



    }

    func configure() {
        bgLayer.strokeColor = bgColor.CGColor
        fgLayer.strokeColor = fgColor.CGColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupShapeLayer(bgLayer)
        setupShapeLayer(fgLayer)
    }
    func DegreesToRadians (value:CGFloat) -> CGFloat {
        return value * CGFloat(M_PI) / 180.0
    }

    func RadiansToDegrees (value:CGFloat) -> CGFloat {
        return value * 180.0 / CGFloat(M_PI)
    }

    func setupShapeLayer(shapeLayer: CAShapeLayer) {

        shapeLayer.frame = self.bounds

        let center = degreeLabel.center
        let radius = CGFloat(CGRectGetWidth(self.bounds) * 0.35)
        let startAngle = DegreesToRadians(135.0)
        let endAngle = DegreesToRadians(45.0)

        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        shapeLayer.path = path.CGPath

    }

    func animate() {

        let currentValueString = String(format: "%.0f", curValue)
        degreeLabel.text = "\(currentValueString)°"

        var fromValue = fgLayer.strokeEnd
        let toValue = curValue / range
        fromValue = fgLayer.presentationLayer()!.strokeEnd
        let pctChange = abs(fromValue - toValue)
       
        // 1
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = toValue
        // 2
        animation.duration = CFTimeInterval(pctChange * 4)
        // 3
        fgLayer.removeAnimationForKey("stroke")
        fgLayer.addAnimation(animation, forKey: "stroke")
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fgLayer.strokeEnd = toValue
        CATransaction.commit()
        
    }

}
