//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by 何鑫 on 16/2/4.
//  Copyright © 2016年 HX.Inc. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: CustomStringConvertible {
		case Operand(Double)
		case UnaryOperation(String, Double -> Double)
		case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
	}

	private var opStack = [Op]()

    private var knowOps = [String : Op]()
    
    init() {
        func learnOp(op: Op) {
            knowOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×") {$0 * $1})
        learnOp(Op.BinaryOperation("÷") {$1 / $0})
        learnOp(Op.BinaryOperation("+") {$0 + $1})
        learnOp(Op.BinaryOperation("−") {$1 - $0})
        learnOp(Op.UnaryOperation("√", sqrt))
    }
    
    var program: AnyObject { // guaranteed to be PropertyList
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
                    }
                }
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainOps: [Op]) {
    	if !ops.isEmpty {
            var remainOps = ops
    		let op = remainOps.removeLast()
            switch op{
            case .Operand(let operand):
                return (operand, remainOps)
            case .UnaryOperation(_, let operation):
            	let operationEvaluate = evaluate(remainOps)
            	if let operand = operationEvaluate.result {
            		return (operation(operand), operationEvaluate.remainOps)
            	}
            case .BinaryOperation(_, let operation):
            	let op1Evaluate = evaluate(remainOps)
            	if let operand1 = op1Evaluate.result {
            		let op2Evaluate = evaluate(op1Evaluate.remainOps)
            		if let operand2 = op2Evaluate.result {
            			return (operation(operand1, operand2), op2Evaluate.remainOps)
            		}
            	}
            }
    	}
    	return (nil, ops)
    }

    func evaluate() -> Double? {
    	let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) and \(remainder) left over")
    	return result
    }

	func pushOperand(operand: Double) -> Double? {
		opStack.append(Op.Operand(operand))
        return evaluate()
	}
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knowOps[symbol] {
        	opStack.append(operation)
        }
        return evaluate()
    }
}