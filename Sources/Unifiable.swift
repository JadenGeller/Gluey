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
    case literal(Element)
    /// A value that is determined by unification.
    case variable(Binding<Element>)
}

extension Unifiable {
    /// Initializes a unifiable variable.
    public static var any: Unifiable {
        return .variable(Binding())
    }
}

extension Unifiable {
    /// The current value otherwise `nil` if it is undetermined.
    public var value: Element? {
        get {
            switch self {
            case .literal(let literalValue):
                return literalValue
            case .variable(let binding):
                return binding.value
            }
        }
    }
}

extension Unifiable: CustomStringConvertible {
    /// A textual representation of the value or the binding if no value exists.
    public var description: String {
        switch self {
        case .literal(let value):
            return String(describing: value)
        case .variable(let binding):
            return binding.description
        }
    }
}

extension Unifiable: UnifiableType {
    /// Unifies `lhs` with `rhs`, otherwise throws a `UnificationError`.
    public static func unify(_ lhs: Unifiable, _ rhs: Unifiable) throws {
        switch (lhs, rhs) {
        case let (.literal(l), .literal(r)):
            guard l == r else {
                throw UnificationError("Cannot unify literals of different values.")
            }
        case let (.literal(l), .variable(r)):
            try Binding.resolve(r, withValue: l)
        case let (.variable(l), .literal(r)):
            try Binding.resolve(l, withValue: r)
        case let (.variable(l), .variable(r)):
            try Binding.unify(l, r)
        }
    }
    
    /// Performs `action` as an operation on `self` such that the
    /// `self` preserves its initial `glue` value if the operation fails.
    public static func attempt(_ value: Unifiable, _ action: () throws -> ()) throws {
        switch value {
        case .literal:
            try action()
        case .variable(let binding):
            try Binding.attempt(binding, action)
        }
    }
}

// Recursive unification
extension Unifiable where Element: UnifiableType {
    /// Recursively unifies `lhs` with `rhs`, otherwise throws a `UnificationError`.
    public static func unify(lhs: Unifiable, _ rhs: Unifiable) throws {
        switch (lhs, rhs) {
        case let (.literal(l), .literal(r)):
            try Element.unify(l, r)
        case let (.literal(l), .variable(r)):
            try Binding.resolve(r, withValue: l)
        case let (.variable(l), .literal(r)):
            try Binding.resolve(l, withValue: r)
        case let (.variable(l), .variable(r)):
            try Binding.unify(l, r)
        }
    }
    
    /// Performs `action` as an operation on `self` such that the
    /// `self` preserves its initial `glue` value if the operation fails.
    public static func attempt(value: Unifiable, _ action: () throws -> ()) throws {
        switch value {
        case .literal(let inner):
            try Element.attempt(inner, action)
        case .variable(let binding):
            try Binding.attempt(binding, action)
        }
    }
}

extension Unifiable: Equatable { }
/// True if `lhs` and `rhs` are the same value or if they are bound together.
public func ==<Element: Equatable>(lhs: Unifiable<Element>, rhs: Unifiable<Element>) -> Bool {
    if let leftValue = lhs.value, let rightValue = rhs.value {
        return leftValue == rightValue
    } else if case let .variable(leftBinding) = lhs, case let .variable(rightBinding) = rhs {
        return leftBinding.glue === rightBinding.glue
    } else {
        return false
    }
}

// MARK: Copying

extension Unifiable: ContextCopyable {
    /// Copies `this` reusing any substructure that has already been copied within
    /// this context, and storing any newly generated substructure into the context.
    public static func copy(_ this: Unifiable, withContext context: CopyContext) -> Unifiable {
        switch this {
        case .literal(let value):
            return .literal(value)
        case .variable(let binding):
            return .variable(Binding.copy(binding, withContext: context))
        }
    }
}

// Recursive copying
extension Unifiable where Element: ContextCopyable {
    /// Copies `this` reusing any substructure that has already been copied within
    /// this context, and storing any newly generated substructure into the context.
    public static func copy(_ this: Unifiable, withContext context: CopyContext) -> Unifiable {
        switch this {
        case .literal(let value):
            return .literal(Element.copy(value, withContext: context))
        case .variable(let binding):
            return .variable(Binding.copy(binding, withContext: context))
        }
    }
}
