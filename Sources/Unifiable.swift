//
//  Unifiable.swift
//  Gluey
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public protocol Unifiable {
    static func unify(lhs: Self, _ rhs: Self) throws
}