//
//  DriedGlue.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// A snapshot of a previous `Glue` value that can be restored at a later date.
internal struct DriedGlue<Element: Equatable> {
    internal var value: Element?
    internal var bindings: Set<Binding<Element>> = []
    
    /// Construct a `Glue` with no bindings that's bound to `value`.
    internal init(glue: Glue<Element>) {
        self.value = glue.value
        self.bindings = glue.bindings
    }
}

extension Glue {
    /// Restore by creating a new `Glue` value from the saved stated, and updating
    /// all saved bindings to utilize this `Glue`.
    internal static func restore(dried: DriedGlue<Element>) {
        let restored = Glue(value: dried.value)
        
        for binding in dried.bindings {
            binding.glue = restored
        }
    }
}