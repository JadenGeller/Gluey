//
//  CopyContext.swift
//  Gluey
//
//  Created by Jaden Geller on 1/31/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public class CopyContext<Value: Equatable> {
    private var backing: [Glue<Value> : Glue<Value>] = [:]
    
    public init() { }
    
    public subscript(oldValue: Glue<Value>) -> Glue<Value> {
        if let newValue = backing[oldValue] {
            return newValue
        } else {
            let newValue = Glue(value: oldValue.value)
            backing[oldValue] = newValue
            return newValue
        }
    }
}

extension Binding {
    public func copy(withContext context: CopyContext<Value> = CopyContext()) -> Binding {
        return Binding(glue: context[glue])
    }
}

extension Term {
    public func copy(withContext context: CopyContext<Value> = CopyContext()) -> Term {
        switch self {
        case .Constant(let value):
            return .Constant(value)
        case .Variable(let binding):
            return .Variable(binding.copy(withContext: context))
        }
    }
}