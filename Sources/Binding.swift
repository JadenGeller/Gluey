//
//  Binding.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// Base unit of unification
public final class Binding<Value: Equatable>: Unifiable {
    public var glue: Glue<Value> {
        willSet { glue.bindings.remove(self) }
        didSet  { glue.bindings.insert(self) }
    }
    
    public init() {
        glue = Glue()
        glue.bindings.insert(self)
    }
    
    public var value: Value? {
        get {
            return glue.value
        }
        set {
            glue.value = newValue
        }
    }
}

// MARK: Hashing

extension Binding: Hashable {
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

public func ==<Value>(lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
    return lhs === rhs
}
