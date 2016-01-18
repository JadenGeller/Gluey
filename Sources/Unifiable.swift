//
//  Unifiable.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public protocol Unifiable {
    /// Unifies `lhs` with `rhs`, otherwise throws a `UnificationError`.
    static func unify(lhs: Self, _ rhs: Self) throws
    
    /// Attempts `action` as an atomic operation on `self` such that the
    /// `glue` preserves its initial value if the operation fails.
    func attempt(action: () throws -> ()) throws
}