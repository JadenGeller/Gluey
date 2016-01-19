//
//  Term.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// Unification type that allows representation of variables and constants,
/// recursively unifying constant values.
public enum Term<Value: Equatable> {
    case Constant(Value)
    case Variable(Binding<Value>)
}

extension Term {
    public var value: Value? {
        switch self {
        case .Constant(let literalValue):
            return literalValue
        case .Variable(let binding):
            return binding.value
        }
    }
}

extension Term: Unifiable {
    /// Unifies `lhs` with `rhs`, otherwise throws a `UnificationError`.
    public static func unify(lhs: Term, _ rhs: Term) throws {
        switch (lhs, rhs) {
        case let (.Constant(l), .Constant(r)):
            guard l == r else {
                throw UnificationError("Cannot unify literals of different values.")
            }
        case let (.Constant(l), .Variable(r)):
            try r.resolve(l)
        case let (.Variable(l), .Constant(r)):
            try l.resolve(r)
        case let (.Variable(l), .Variable(r)):
            try Binding.unify(l, r)
        }
    }
    
    public func attempt(action: () throws -> ()) throws {
        switch self {
        case .Constant:
            try action()
        case .Variable(let binding):
            try binding.attempt(action)
        }
    }
}

// Recursive unification
extension Term where Value: Unifiable {
    public static func unify(lhs: Term, _ rhs: Term) throws {
        switch (lhs, rhs) {
        case let (.Constant(l), .Constant(r)):
            try Value.unify(l, r)
        case let (.Constant(l), .Variable(r)):
            try r.resolve(l)
        case let (.Variable(l), .Constant(r)):
            try l.resolve(r)
        case let (.Variable(l), .Variable(r)):
            try Binding.unify(l, r)
        }
    }
}

extension Term: Equatable { }
/// True if `lhs` and `rhs` are the same value or if they share the same binding
public func ==<Value: Equatable>(lhs: Term<Value>, rhs: Term<Value>) -> Bool {
    if let leftValue = lhs.value, rightValue = rhs.value {
        return leftValue == rightValue
    } else if case let .Variable(leftBinding) = lhs, case let .Variable(rightBinding) = rhs {
        return leftBinding.glue === rightBinding.glue
    } else {
        return false
    }
}
