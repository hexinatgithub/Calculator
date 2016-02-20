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

    func minAndMaxYValueForGraphView(minX minX: CGFloat, maxX: CGFloat) -> (minY: CGFloat, maxY: CGFloat)? {
        if let result = brain?.evaluate() {
            return (CGFloat(result), CGFloat(result))
        } else if brain?.lastExpression?.rangeOfString("M") != nil {
            brain?.variableValues["M"] = minX.native
            let minY = brain?.evaluate()
            brain?.variableValues["M"] = maxX.native
            let maxY = brain?.evaluate()
            brain?.variableValues["M"] = nil
            return (CGFloat(minY!), CGFloat(maxY!))
        }
        return nil
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
