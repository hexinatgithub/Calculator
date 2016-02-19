//
//  GraphView.swift
//  Calculator
//
//  Created by 何鑫 on 16/2/19.
//  Copyright © 2016年 HX.Inc. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {

}

@IBDesignable
class GraphView: UIView {
    
    // MARK: Property
    var axesOrigin: CGPoint = CGPointZero { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var axesScale: CGFloat = 50 { didSet { setNeedsDisplay() } }
    
    // MARK: DataSource
    var dataSource: GraphViewDataSource?

    // MARK: Function
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let axesDrawer = AxesDrawer(color: UIColor.blackColor())
        axesDrawer.drawAxesInRect(bounds, origin: axesOrigin, pointsPerUnit: axesScale)
    }
    
    func pinch(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            axesScale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .Changed {
            let translation = gesture.translationInView(self)
            axesOrigin = CGPoint(x: translation.x + axesOrigin.x, y: translation.y + axesOrigin.y)
            gesture.setTranslation(CGPointZero, inView: self)
        }
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            let point = gesture.locationInView(self)
            axesOrigin = point
        }
    }
    
}
