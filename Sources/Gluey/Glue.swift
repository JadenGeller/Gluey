//
//  Glue.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// Tracks which bindings are unified together and stores the value
/// shared between these bindings.
internal final class Glue<Element: Equatable> {
    internal var value: Element?
    internal var bindings: Set<Binding<Element>> = []
    
    /// Construct a `Glue` with no bindings that's bound to `value`.
    internal init(value: Element? = nil) {
        self.value = value
    }
}

extension Glue {
    /// If all `Glue` in the array can be unified without value conflicts, returns
    /// the resulting value or `nil` if no `Glue` has a value. If a conflict exists,
    /// throws a `UnificationError`.
    private static func unifiedValue(_ glue: [Glue]) throws -> Element? {
        // If glue values conflict, throw unification error.
        // Otherwise, return the unified value.
        return try glue.map{ $0.value }.reduce(nil) {
            if let a = $0, let b = $1, a != b {
                throw UnificationError("Cannot unify bindings that are bound to different literal values.")
            }
            return $0 ?? $1
        }
    }
    
    /// Merge all `Glue` in the array and update each's bindings to reflect their
    /// newly merged `Glue`. If multiple `Glue` have values set and they disagree,
    /// throws a `UnfiicationError`.
    internal static func merge(_ glue: [Glue]) throws {
        let merged = try Glue(value: unifiedValue(glue))
        
        // Update each binding to use this glue.
        glue.flatMap{ $0.bindings }.forEach{
            $0.glue = merged
        }
    }
}

