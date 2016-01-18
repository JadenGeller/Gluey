//
//  Unifiable.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public protocol Unifiable {
    typealias Value: Equatable
    var glue: Glue<Value> { get }
}

extension Unifiable {
    /// Unifies `lhs` with `rhs`, otherwise throws a `UnificationError`.
    public static func unify(lhs: Self, _ rhs: Self) throws {
        try Glue.merge([lhs.glue, rhs.glue])
    }
    
    /// Attempts `action` as an atomic operation on `self` such that the
    /// `glue` preserves its initial value if the operation fails.
    public func attempt(action: () throws -> ()) throws {
        let dried = DriedGlue(glue: glue)
        do {
            try action()
        } catch let error as UnificationError {
            Glue.restore(dried)
            throw error // rethrow!
        }
    }
}