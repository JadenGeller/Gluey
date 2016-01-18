//
//  Term.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

// Unification type that wraps `Binding` for better use with literal values
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