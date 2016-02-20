//
//  GraphViewController.swift
//  Calculator
//
//  Created by 何鑫 on 16/2/19.
//  Copyright © 2016年 HX.Inc. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    // MARK: Modal
    var canTouch: Bool = true {
        didSet {
            graphView.userInteractionEnabled = canTouch
        }
    }
    
    var brain: CalculatorBrain?
    
    // MARK: View
    @IBOutlet var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.userInteractionEnabled = canTouch
            let pinch = UIPinchGestureRecognizer(target: graphView, action: "pinch:")
            graphView.addGestureRecognizer(pinch)
            let pan = UIPanGestureRecognizer(target: graphView, action: "pan:")
            graphView.addGestureRecognizer(pan)
            let doubleTap = UITapGestureRecognizer(target: graphView, action: "tap:")
            doubleTap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTap)
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        graphView.axesOrigin = graphView.center
    }

    // MARK: Function
    func updateUI() {
        graphView.setNeedsDisplay()
    }

    func pointsForGraphView(sender: GraphView) -> [CGPoint]? {
        if brain?.lastExpression?.rangeOfString("?") == nil {
            var points = [CGPoint]()
            var minX = sender.minX.native
            let maxX = sender.maxX.native
            let increment = sender.incrementX.native
            while minX <= maxX {
                if let y = brain?.yFor("M", value: minX) {
                    points.append(CGPoint(x: minX, y: y))
                }
                minX += increment
            }
            return points
        }
        return nil
    }

}
