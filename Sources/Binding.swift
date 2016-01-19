//
//  Binding.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// Base unit of unification
public final class Binding<Value: Equatable> {
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

extension Binding {
    public func resolve(newValue: Value) throws {
        if let value = value {
            guard value == newValue else {
                throw UnificationError("Cannot resolve binding already bound to a different value.")
            }
        } else {
            value = newValue
        }
    }
}

extension Binding: CustomStringConvertible {
    public var description: String {
        if let value = value {
            return String(value)
        } else {
            return "_B" + String(ObjectIdentifier(glue).uintValue)
        }
    }
}

// MARK: Hashing

extension Binding: Hashable {
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

// Reference identity
public func ==<Value>(lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
    return lhs === rhs
}

// MARK: Unifiable

extension Binding: Unifiable {
    public static func unify(lhs: Binding, _ rhs: Binding) throws {
        try Glue.merge([lhs.glue, rhs.glue])
    }
    
    /// Attempts `action` as an atomic operation on `self` such that the
    /// `glue` preserves its initial value if the operation fails.
    public static func attempt(value: Binding, _ action: () throws -> ()) throws {
        let dried = DriedGlue(glue: value.glue)
        do {
            try action()
        } catch let error as UnificationError {
            Glue.restore(dried)
            throw error // rethrow!
        }
    }
}
