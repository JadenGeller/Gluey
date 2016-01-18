//
//  UnificationError.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public struct UnificationError: ErrorType {
    public init(_ message: String) {
        self.message = message
    }
    
    public let message: String
}