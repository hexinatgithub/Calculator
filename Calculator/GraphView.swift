//
//  GraphView.swift
//  Calculator
//
//  Created by 何鑫 on 16/2/19.
//  Copyright © 2016年 HX.Inc. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func pointsForGraphView(sender: GraphView) -> [CGPoint]?
}

@IBDesignable
class GraphView: UIView {
    
    // MARK: Property
    var lineWidth = CGFloat(1) { didSet{ setNeedsDisplay() } }
    var lineColor = UIColor.blueColor() { didSet{ setNeedsDisplay() } }
    var minX: CGFloat {
        return (bounds.minX - axesOrigin.x) / axesScale
    }
    var maxX: CGFloat {
        return (bounds.maxX - axesOrigin.x) / axesScale
    }
    var incrementX: CGFloat {
        return 1 / axesScale
    }
    
    @IBInspectable
    var axesScale: CGFloat = 50 { didSet { setNeedsDisplay() } }
    var axesOrigin: CGPoint = CGPointZero { didSet { setNeedsDisplay() } }
    var axesDrawer: AxesDrawer!
    
    // MARK: DataSource
    var dataSource: GraphViewDataSource?

    // MARK: Function
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        axesDrawer = AxesDrawer(color: UIColor.blackColor())
        axesDrawer.drawAxesInRect(bounds, origin: axesOrigin, pointsPerUnit: axesScale)
        axesDrawer.contentScaleFactor = contentScaleFactor
        if var points = dataSource?.pointsForGraphView(self) {
            let path = UIBezierPath()
            path.lineWidth = lineWidth
            lineColor.set()
            if !points.isEmpty {
                let first = points.removeFirst()
                path.moveToPoint(CGPoint(x: first.x * axesScale + axesOrigin.x, y: -first.y * axesScale + axesOrigin.y) )
                for point in points {
                    path.addLineToPoint(CGPoint(x: point.x * axesScale + axesOrigin.x, y: -point.y * axesScale + axesOrigin.y))
                }
            }
            path.stroke()
        }
    }
    
    // MARK: Gesture function
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
            axesOrigin = gesture.locationInView(self)
        }
    }
}
