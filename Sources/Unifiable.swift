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
    static func attempt(value: Self, _ action: () throws -> ()) throws
}

// Note that attempt is a static function so that it can be overloaded in a
// conditional extension. I'm not sure if this is intended behavior or a
// limitation of Swift. Also note that a convenience attempt that takes in
// an array of terms cannot be defined since it would never choose a 
// conditional overload (because of how Swift generic work), and thus will
// cause unexpected, silent failures with recursive unification types.