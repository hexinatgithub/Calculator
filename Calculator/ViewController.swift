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
    
    var usrIsInTheMiddleOfTypingANumber : Bool = false
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if usrIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            usrIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if usrIsInTheMiddleOfTypingANumber {
            enter()
        }
        switch operation{
            case "×":   performOperation {$0 * $1}

            case "÷":   performOperation {$1 / $0}

            case "+":   performOperation {$0 + $1}

            case "−":   performOperation {$1 - $0}
            
            case "√":   performOperation {sqrt($0)}
            
            default: break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double){
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    private func performOperation(operation: Double -> Double){
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    var operandStack = Array<Double>()
    @IBAction func enter() {
        usrIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        print("operandStack = \(operandStack)")
    }
    
    var displayValue: Double{
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            display.text = "\(newValue)"
            usrIsInTheMiddleOfTypingANumber = false
        }
    }
}

