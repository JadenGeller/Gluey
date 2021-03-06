//
//  UnificationError.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// Error thrown when `UnifiableType` types fail to unify.
public struct UnificationError: Error {
    public init(_ message: String) {
        self.message = message
    }
    
    /// The cause for the failure.
    public let message: String
}
