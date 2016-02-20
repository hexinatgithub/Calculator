//
//  GraphView.swift
//  Calculator
//
//  Created by 何鑫 on 16/2/19.
//  Copyright © 2016年 HX.Inc. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func minAndMaxYValueForGraphView(minX minX: CGFloat, maxX: CGFloat) -> (minY: CGFloat, maxY: CGFloat)?
}

@IBDesignable
class GraphView: UIView {
    private struct Point {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var xInScreen: CGFloat {
            return CGFloat(x) * dataSource.axesScale + dataSource.axesOrigin.x
        }
        var yInScreen: CGFloat {
            return CGFloat(-y) * dataSource.axesScale + dataSource.axesOrigin.y
        }
        var pointInScreen: CGPoint {
            return CGPoint(x: xInScreen, y: yInScreen)
        }
        
        unowned let dataSource: GraphView
        
        init(x: CGFloat, y: CGFloat, dataSource: GraphView) {
            self.x = x
            self.y = y
            self.dataSource = dataSource
        }
        
        var description: String {
            return "(\(x.native),\(y.native))"
        }
    }
    
    // MARK: Property
    var axesOrigin: CGPoint = CGPointZero { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var axesScale: CGFloat = 50 { didSet { setNeedsDisplay() } }
    
    var axesDrawer: AxesDrawer!
    
    // MARK: DataSource
    var dataSource: GraphViewDataSource?

    // MARK: Function
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        axesDrawer = AxesDrawer(color: UIColor.blackColor())
        axesDrawer.drawAxesInRect(bounds, origin: axesOrigin, pointsPerUnit: axesScale)
        axesDrawer.contentScaleFactor = contentScaleFactor
//        drawCurve()
    }
    
    private func drawLine() {
        let minX = (bounds.minX - axesOrigin.x) / axesScale
        let maxX = (bounds.maxX - axesOrigin.x) / axesScale
        if let (y1, y2) = dataSource?.minAndMaxYValueForGraphView(minX: minX, maxX: maxX) {
            let path = UIBezierPath()
            let point1 = Point(x: minX, y: y1, dataSource: self)
            let point2 = Point(x: maxX, y: y2, dataSource: self)
//            print("\(point1.description), \(point2.description)")
            path.moveToPoint(point1.pointInScreen)
            path.addLineToPoint(point2.pointInScreen)
            path.stroke()
        }
    }
    
    private func drawCurve() {
//        let path = UIBezierPath()
//        UIColor.blueColor()
//        let point1 = Point(x: 0, y: 0, dataSource: self)
//        path.moveToPoint(point1.pointInScreen)
//        let point2 = Point(x: 1, y: 0, dataSource: self)
//        let cpoint1 = Point(x: 0, y: 1, dataSource: self)
//        let cpoint2 = Point(x: 1, y: 1, dataSource: self)
//        path.addCurveToPoint(point2.pointInScreen, controlPoint1: cpoint1.pointInScreen, controlPoint2: cpoint2.pointInScreen)
//        path.stroke()
//        func sin(x1: CGFloat, x2: CGFloat) {
//            let path = UIBezierPath()
//            var point1 = Point(x: x1, y: 0, dataSource: self)
//            path.moveToPoint(point1.pointInScreen)
//            var cpoint1 = Point(x: x1, y: 1, dataSource: self)
//            var point2 = Point(x: (x1 + x2) / 2.0, y: 1, dataSource: self)
//            path.addQuadCurveToPoint(point2.pointInScreen, controlPoint: cpoint1.pointInScreen)
//            path.stroke()
//            point1 = point2
//            point2 = Point(x: x2, y: 0, dataSource: self)
//            cpoint1 = Point(x: x2, y: 1, dataSource: self)
//            path.moveToPoint(point1.pointInScreen)
//            path.addQuadCurveToPoint(point2.pointInScreen, controlPoint: cpoint1.pointInScreen)
//            path.stroke()
//        }
//        sin(0, x2: 2)
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
            axesOrigin = gesture.locationInView(self)
        }
    }
}
