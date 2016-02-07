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
        case    SignalOperation(String, () -> Double)

        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let operation, _):
                    return "\(operation)"
                case .BinaryOperation(let operation, _):
                    return "\(operation)"
                case .SignalOperation:
                    return "π"
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var konwOps = [String : Op]()
    
    init() {
        func learnOps(op: Op) {
            konwOps[op.description] = op
        }
        learnOps(Op.BinaryOperation("+", +))
        learnOps(Op.BinaryOperation("-") { $1 - $0 })
        learnOps(Op.BinaryOperation("×", *))
        learnOps(Op.BinaryOperation("÷") { $1 / $0 })
        learnOps(Op.UnaryOperation("√") { sqrt($0) })
        learnOps(Op.UnaryOperation("sin") { sin($0) })
        learnOps(Op.UnaryOperation("cos") { cos($0) })
        learnOps(Op.SignalOperation("π") { M_PI })
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainOpStack: [Op]) {
        if !ops.isEmpty {
            var raminStack = ops
            let op = raminStack.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, raminStack)
            case .UnaryOperation(_ , let operation):
                let operandEvaluate = evaluate(raminStack)
                if let op1 = operandEvaluate.result {
                    return (operation(op1), raminStack)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluate = evaluate(raminStack)
                if let op1 = op1Evaluate.result {
                    let op2Evaluate = evaluate(op1Evaluate.remainOpStack)
                    if let op2 = op2Evaluate.result {
                        return (operation(op1, op2), op2Evaluate.remainOpStack)
                    }
                }
            case .SignalOperation(_, let operation):
                return (operation(), raminStack)
            }
        }
        return (nil, ops)
    }
    
    private func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        if result != nil {
            print("\(opStack) = \(result) left over \(remainder)")
            return result
        }
        return nil
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        if let result = evaluate() {
            return result
        }
        return nil
    }
    
    func performOperation(operation: String) -> Double? {
        if let op = konwOps[operation] {
            opStack.append(op)
            if let result = evaluate() {
                return result
            }
        }
        return nil
    }
    
    func clear() {
        opStack.removeAll()
    }
}