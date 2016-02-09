//
//  Unifiable.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// Recursively unifiable type that allows for representation of both variables
/// and constant values. May be used as a building block to build tree-like
/// unification types.
public enum Unifiable<Element: Equatable> {
    /// A value that cannot be changed.
    case Constant(Element)
    /// A value that is determined by unification.
    case Variable(Binding<Element>)
}

extension Unifiable {
    /// The current value otherwise `nil` if it is undetermined.
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

extension Unifiable: CustomStringConvertible {
    /// A textual representation of the value or the binding if no value exists.
    public var description: String {
        switch self {
        case .Constant(let value):
            return String(value)
        case .Variable(let binding):
            return binding.description
        }
    }
}

extension Unifiable: UnifiableType {
    /// Unifies `lhs` with `rhs`, otherwise throws a `UnificationError`.
    public static func unify(lhs: Unifiable, _ rhs: Unifiable) throws {
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
    
    /// Performs `action` as an operation on `self` such that the
    /// `self` preserves its initial `glue` value if the operation fails.
    public static func attempt(value: Unifiable, _ action: () throws -> ()) throws {
        switch value {
        case .Constant:
            try action()
        case .Variable(let binding):
            try Binding.attempt(binding, action)
        }
    }
}

// Recursive unification
extension Unifiable where Element: UnifiableType {
    /// Recursively unifies `lhs` with `rhs`, otherwise throws a `UnificationError`.
    public static func unify(lhs: Unifiable, _ rhs: Unifiable) throws {
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
    
    /// Performs `action` as an operation on `self` such that the
    /// `self` preserves its initial `glue` value if the operation fails.
    public static func attempt(value: Unifiable, _ action: () throws -> ()) throws {
        switch value {
        case .Constant(let inner):
            try Element.attempt(inner, action)
        case .Variable(let binding):
            try Binding.attempt(binding, action)
        }
    }
}

extension Unifiable: Equatable { }
/// True if `lhs` and `rhs` are the same value or if they are bound together.
public func ==<Element: Equatable>(lhs: Unifiable<Element>, rhs: Unifiable<Element>) -> Bool {
    if let leftValue = lhs.value, rightValue = rhs.value {
        return leftValue == rightValue
    } else if case let .Variable(leftBinding) = lhs, case let .Variable(rightBinding) = rhs {
        return leftBinding.glue === rightBinding.glue
    } else {
        return false
    }
}

// MARK: Copying

extension Unifiable: ContextCopyable {
    /// Copies `this` reusing any substructure that has already been copied within
    /// this context, and storing any newly generated substructure into the context.
    public static func copy(this: Unifiable, withContext context: CopyContext) -> Unifiable {
        switch this {
        case .Constant(let value):
            return .Constant(value)
        case .Variable(let binding):
            return .Variable(Binding.copy(binding, withContext: context))
        }
    }
}

// Recursive copying
extension Unifiable where Element: ContextCopyable {
    /// Copies `this` reusing any substructure that has already been copied within
    /// this context, and storing any newly generated substructure into the context.
    public static func copy(this: Unifiable, withContext context: CopyContext) -> Unifiable {
        switch this {
        case .Constant(let value):
            return .Constant(Element.copy(value, withContext: context))
        case .Variable(let binding):
            return .Variable(Binding.copy(binding, withContext: context))
        }
    }
}
