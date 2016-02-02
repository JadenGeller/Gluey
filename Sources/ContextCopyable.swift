//
//  ContextCopyable.swift
//  Gluey
//
//  Created by Jaden Geller on 1/31/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public protocol ContextCopyable {
    static func copy(this: Self, withContext context: CopyContext) -> Self
}

private struct AnyGlue: Hashable {
    let glue: AnyObject
    
    init<Value: Equatable>(_ glue: Glue<Value>) {
        self.glue = glue
    }
    
    var hashValue: Int {
        return ObjectIdentifier(glue).hashValue
    }
}
private func ==(lhs: AnyGlue, rhs: AnyGlue) -> Bool {
    return lhs.glue === rhs.glue
}

public final class CopyContext {
    private var backing: [AnyGlue : AnyGlue] = [:]
    
    public init() { }
    
    public func copy<Value: Equatable>(oldValue: Glue<Value>) -> Glue<Value> {
        if let newValue = backing[AnyGlue(oldValue)] {
            return newValue.glue as! Glue<Value>
        } else {
            let newValue = Glue(value: oldValue.value)
            backing[AnyGlue(oldValue)] = AnyGlue(newValue)
            return newValue
        }
    }
}