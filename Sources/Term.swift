//
//  Value.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// Unification type that allows representation of variables and constants,
/// recursively unifying constant values.
public enum Value<Element: Equatable> {
    case Constant(Element)
    case Variable(Binding<Element>)
}

extension Value {
    public var value: Element? {
        get {
            switch self {
            case .Constant(let literalValue):
                return literalValue
            case .Variable(let binding):
                return binding.value
            }
        }
    }
}

extension Value: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Constant(let value):
            return String(value)
        case .Variable(let binding):
            return binding.description
        }
    }
}

extension Value: Unifiable {
    /// Unifies `lhs` with `rhs`, otherwise throws a `UnificationError`.
    public static func unify(lhs: Value, _ rhs: Value) throws {
        switch (lhs, rhs) {
        case let (.Constant(l), .Constant(r)):
            guard l == r else {
                throw UnificationError("Cannot unify literals of different values.")
            }
        case let (.Constant(l), .Variable(r)):
            try Binding.resolve(r, withValue: l)
        case let (.Variable(l), .Constant(r)):
            try Binding.resolve(l, withValue: r)
        case let (.Variable(l), .Variable(r)):
            try Binding.unify(l, r)
        }
    }
    
    public static func attempt(value: Value, _ action: () throws -> ()) throws {
        switch value {
        case .Constant:
            try action()
        case .Variable(let binding):
            try Binding.attempt(binding, action)
        }
    }
}

// Recursive unification
extension Value where Element: Unifiable {
    public static func unify(lhs: Value, _ rhs: Value) throws {
        switch (lhs, rhs) {
        case let (.Constant(l), .Constant(r)):
            try Element.unify(l, r)
        case let (.Constant(l), .Variable(r)):
            try Binding.resolve(r, withValue: l)
        case let (.Variable(l), .Constant(r)):
            try Binding.resolve(l, withValue: r)
        case let (.Variable(l), .Variable(r)):
            try Binding.unify(l, r)
        }
    }
    
    public static func attempt(value: Value, _ action: () throws -> ()) throws {
        switch value {
        case .Constant(let inner):
            try Element.attempt(inner, action)
        case .Variable(let binding):
            try Binding.attempt(binding, action)
        }
    }
}

extension Value: Equatable { }
/// True if `lhs` and `rhs` are the same value or if they share the same binding
public func ==<Element: Equatable>(lhs: Value<Element>, rhs: Value<Element>) -> Bool {
    if let leftValue = lhs.value, rightValue = rhs.value {
        return leftValue == rightValue
    } else if case let .Variable(leftBinding) = lhs, case let .Variable(rightBinding) = rhs {
        return leftBinding.glue === rightBinding.glue
    } else {
        return false
    }
}

// MARK: Copying

extension Value: ContextCopyable {
    public static func copy(this: Value, withContext context: CopyContext) -> Value {
        switch this {
        case .Constant(let value):
            return .Constant(value)
        case .Variable(let binding):
            return .Variable(Binding.copy(binding, withContext: context))
        }
    }
}

// Recursive copying
extension Value where Element: ContextCopyable {
    public static func copy(this: Value, withContext context: CopyContext) -> Value {
        switch this {
        case .Constant(let value):
            return .Constant(Element.copy(value, withContext: context))
        case .Variable(let binding):
            return .Variable(Binding.copy(binding, withContext: context))
        }
    }
}
