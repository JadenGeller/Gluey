//
//  Glue.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// Holds together bindings and manages their value
public class Glue<Value: Equatable> {
    internal var value: Value?
    internal var bindings: Set<Binding<Value>> = []
    
    /// Construct a `Glue` with no bindings that's bound to `value`.
    internal init(value: Value? = nil) {
        self.value = value
    }
}

extension Glue {
    /// Unified value of multiple glue values or throw if unification is not possible
    public static func unifiedValue(glue: [Glue]) throws -> Value? {
        // If glue values conflict, throw unification error.
        // Otherwise, return the unified value.
        return try glue.map{ $0.value }.reduce(nil) {
            if let a = $0, b = $1 where a != b {
                throw UnificationError("Cannot unify bindings that are bound to different literal values.")
            }
            return $0 ?? $1
        }
    }
    
    // Merge multiple glue and update the bindings
    public static func merge(glue: [Glue]) throws {
        let merged = try Glue(value: unifiedValue(glue))
        
        // Update each binding to use this glue.
        glue.flatMap{ $0.bindings }.forEach{
            $0.glue = merged
        }
    }
}
