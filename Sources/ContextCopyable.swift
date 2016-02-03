//
//  ContextCopyable.swift
//  Gluey
//
//  Created by Jaden Geller on 1/31/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// Instances of conforming types can be copied such if values `f` and `g` are unified,
/// then copies `f'` and `g'` will also be unified, but the copies will not be unified
/// with te original values.
public protocol ContextCopyable {
    /// Copies `this` reusing any substructure that has already been copied within
    /// this context, and storing any newly generated substructure into the context.
    static func copy(this: Self, withContext context: CopyContext) -> Self
}

/// Defines context in which copying occurs such that repeated substructure
/// maintains shared glue between bindings.
public final class CopyContext {
    private var backing: [AnyGlue : AnyGlue] = [:]
    
    /// Constructs an empty context.
    public init() { }
    
    /// Creates a copy of a given `Glue` value and stores it for future use,
    /// or returns an existing copy of the given `Glue` if it has already been
    /// copied within this context.
    internal func copy<Element: Equatable>(oldValue: Glue<Element>) -> Glue<Element> {
        if let newValue = backing[AnyGlue(oldValue)] {
            return newValue.glue as! Glue<Element>
        } else {
            let newValue = Glue(value: oldValue.value)
            backing[AnyGlue(oldValue)] = AnyGlue(newValue)
            return newValue
        }
    }
}

private struct AnyGlue: Hashable {
    let glue: AnyObject
    
    init<Element: Equatable>(_ glue: Glue<Element>) {
        self.glue = glue
    }
    
    var hashValue: Int {
        return ObjectIdentifier(glue).hashValue
    }
}
private func ==(lhs: AnyGlue, rhs: AnyGlue) -> Bool {
    return lhs.glue === rhs.glue
}
