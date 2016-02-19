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

    
    // MARK: View
    @IBOutlet var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
