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
    private var brain = CalculatorBrain() {
        didSet {
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "historyChange:", name: "historyChange", object: nil)
            print("did set brain")
        }
    }
    var usrIsInTheMiddleOfTypingANumber : Bool = false
    var displayValue: Double? {
        get{
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set{
            if let value = newValue {
                display?.text = "\(value)"
            }else {
                display?.text = " "
            }
            usrIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func clear() {
        brain.clearOpStack()
        brain.clearVariables()
        displayValue = nil
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
            displayValue = brain.performOperation(operation)
        }
    }

    @IBAction func pushVariable(sender: UIButton) {
        if usrIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let variable = sender.currentTitle {
            displayValue = brain.pushOperand(variable)
        }
        usrIsInTheMiddleOfTypingANumber = false
    }
        
    @IBAction func setVariable(sender: UIButton) {
        if let variable = sender.currentTitle {
            brain.setVariable(variable, toValue: displayValue)
        }
        displayValue = brain.evaluate()
    }
    
    @IBAction func enter() {
        usrIsInTheMiddleOfTypingANumber = false
        if let value = displayValue {
            if let result = brain.pushOperand(value) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    func historyChange(notification: NSNotification) {
        historyDisplay.text = brain.description.isEmpty ? "" : (brain.description + "=")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "historyChange:", name: "historyChange", object: nil)
    }
}

