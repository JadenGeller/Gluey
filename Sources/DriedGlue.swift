//
//  DriedGlue.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public struct DriedGlue<Value: Equatable> {
    internal var value: Value?
    internal var bindings: Set<Binding<Value>> = []
    
    /// Construct a `Glue` with no bindings that's bound to `value`.
    internal init(glue: Glue<Value>) {
        self.value = glue.value
        self.bindings = glue.bindings
    }
}

extension Glue {
    public static func restore(dried: DriedGlue<Value>) {
        let restored = Glue(value: dried.value)
        
        for binding in dried.bindings {
            binding.glue = restored
        }
    }
}