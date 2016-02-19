//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by 何鑫 on 16/2/7.
//  Copyright © 2016年 HX.Inc. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: CustomStringConvertible {
        case    Operand(Double)
        case    UnaryOperation(String, Double -> Double)
        case    BinaryOperation(String, (Double, Double) -> Double)
        case    Variable(String)
        case    Constant(String, Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let operation, _):
                    return "\(operation)"
                case .BinaryOperation(let operation, _):
                    return "\(operation)"
                case .Variable(let variable):
                    return "\(variable)"
                case .Constant(let constant, _):
                    return "\(constant)"
                }
            }
        }
    }
    
    private var opStack = [Op]() {
        didSet {
            let ntf = NSNotification(name: "historyChange", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(ntf)
        }
    }
    
    private var knowOps = [String : Op]()
    
    private var program: AnyObject { // guaranteed to be PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let operation = knowOps[opSymbol] {
                        newOpStack.append(operation)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    } else {
                        newOpStack.append(.Variable(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private var programVariable: AnyObject {
        get {
            return variableValues
        }
        set {
            if let variables = newValue as? Dictionary<String, Double> {
                variableValues = variables
            }
        }
    }
    
    private var variableValues = Dictionary<String, Double>()
    
    var description: String {
        return multipleExpression()
    }
    
    
    
    func setVariable(variable: String, toValue value: Double?) {
        variableValues[variable] = value
    }

    private func expression(ops: [Op]) -> (dsp: String?, remainStack: [Op]) {
        if !ops.isEmpty {
            var remainStack = ops
            let op = remainStack.removeLast()
            switch op {
            case .Variable(let variable):
                return (variable, remainStack)
            case .Operand(let operand):
                return ("\(operand)", remainStack)
            case .UnaryOperation(let operation, _):
                let op1Description = expression(remainStack)
                if var op = op1Description.dsp {
                    op = op != "" ? op : "?"
                    let exp = operation + "(" + op + ")"
                    return (exp, op1Description.remainStack)
                }
            case .BinaryOperation(let operation, _):
                func parentheses(inout op: String, ops: [Op]) {
                    if op != "?" {
                        if let item = ops.last {
                            switch item{
                            case .BinaryOperation:
                                op = "(" + op + ")"
                            default: break
                            }
                        }
                    }
                }
                
                let op1Description = expression(remainStack)
                var op1 = op1Description.dsp ?? "?"
                parentheses(&op1, ops: remainStack)
                let op2Description = expression(op1Description.remainStack)
                var op2 = op2Description.dsp ?? "?"
                parentheses(&op2, ops: op1Description.remainStack)
                let exp = op2 + operation + op1
                return (exp, op2Description.remainStack)
            case .Constant(let constant, _):
                return (constant, remainStack)
            }
        }
        return (nil, ops)
    }

    private func multipleExpression() -> String {
        var dsc = ""
        var separate = ""
        var expressionDescription = expression(opStack)
        while let s = expressionDescription.dsp {
            dsc = s + separate + dsc
            separate = ","
            expressionDescription = expression(expressionDescription.remainStack)
        }
        return dsc
    }
    
    init() {
        func learnOps(op: Op) {
            knowOps[op.description] = op
        }
        learnOps(Op.BinaryOperation("+", +))
        learnOps(Op.BinaryOperation("−") { $1 - $0 })
        learnOps(Op.BinaryOperation("×", *))
        learnOps(Op.BinaryOperation("÷") { $1 / $0 })
        learnOps(Op.UnaryOperation("√") { sqrt($0) })
        learnOps(Op.UnaryOperation("sin") { sin($0) })
        learnOps(Op.UnaryOperation("cos") { cos($0) })
        learnOps(Op.Constant("π", M_PI))
        retrieveData()
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainOpStack: [Op]) {
        if !ops.isEmpty {
            var remainStack = ops
            let op = remainStack.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainStack)
            case .Variable(let variable):
                return (variableValues[variable], remainStack)
            case .UnaryOperation(_ , let operation):
                let operandEvaluate = evaluate(remainStack)
                if let op1 = operandEvaluate.result {
                    return (operation(op1), operandEvaluate.remainOpStack)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluate = evaluate(remainStack)
                if let op1 = op1Evaluate.result {
                    let op2Evaluate = evaluate(op1Evaluate.remainOpStack)
                    if let op2 = op2Evaluate.result {
                        return (operation(op1, op2), op2Evaluate.remainOpStack)
                    }
                }
            case .Constant(_, let constantValue):
                return (constantValue, remainStack)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        return evaluate(opStack).result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        if let result = evaluate() {
            return result
        }
        return nil
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(operation: String) -> Double? {
        if let op = knowOps[operation] {
            opStack.append(op)
            if let result = evaluate() {
                return result
            }
        }
        return nil
    }
    
    func clearOpStack() {
        opStack.removeAll()
    }
    
    func clearVariables() {
        variableValues.removeAll()
    }
    
    deinit {
        save()
    }
    
    func save() {
        let userDefaut = NSUserDefaults()
        userDefaut.setObject(program, forKey: "program")
        userDefaut.setObject(programVariable, forKey: "programVariable")
    }
    
    private func retrieveData() {   // retrieve data
        let userDefaut = NSUserDefaults()
        if let data = userDefaut.valueForKey("program") {
            program = data
        }
        if let data = userDefaut.valueForKey("programVariable") {
            programVariable = data
        }
    }
}
