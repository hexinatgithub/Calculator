//
//  ViewController.swift
//  Calculator
//
//  Created by 何鑫 on 16/2/1.
//  Copyright © 2016年 HX.Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyDisplay: UILabel!
    private var brain = CalculatorBrain()
    var usrIsInTheMiddleOfTypingANumber : Bool = false
    var displayValue: Double {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            display.text = "\(newValue)"
            usrIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func clear() {
        brain.reset()
        display.text = "0"
        usrIsInTheMiddleOfTypingANumber = false
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        var digit = sender.currentTitle!
        digit = display.text!.rangeOfString(".") != nil && digit == "." ? "" : digit
        if usrIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            usrIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if usrIsInTheMiddleOfTypingANumber {
            enter()
        }

        let title = sender.currentTitle
        if let operation = title {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
        
    @IBAction func enter() {
        usrIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    func historyChange(notification: NSNotification) {
        historyDisplay.text = brain.history()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "historyChange:", name: "historyChange", object: brain)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

