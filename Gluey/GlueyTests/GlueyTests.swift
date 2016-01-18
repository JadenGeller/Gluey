//
//  GlueyTests.swift
//  GlueyTests
//
//  Created by Jaden Geller on 1/18/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
import Gluey

class GlueyTests: XCTestCase {
    
    func testUnificationWithDelayedValueSet() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        
        try! Binding.unify(a, b)
        a.value = 10
        XCTAssertEqual(10, b.value)
    }
    
    func testUnificationWithEagerValueSet() {
        let a = Binding<Int>()
        a.value = 10
        let b = Binding<Int>()
        
        try! Binding.unify(a, b)
        XCTAssertEqual(10, b.value)
    }
    
    func testChainedUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        let c = Binding<Int>()
        
        try! Binding.unify(a, b)
        try! Binding.unify(b, c)
        c.value = 10
        
        XCTAssertEqual(a.value, 10)
        XCTAssertEqual(b.value, 10)
    }
    
    func testSuccessfulUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        
        a.value = 10
        b.value = 10
        
        try! Binding.unify(a, b)
    }
    
    func testSuccessfulChainedUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        let c = Binding<Int>()
        
        a.value = 10
        c.value = 10
        
        try! Binding.unify(a, b)
        try! Binding.unify(b, c)
    }
    
    func testFailedUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        
        a.value = 10
        b.value = 20
        
        do {
            try Binding.unify(a, b)
            XCTFail()
        } catch { }
    }
    
    func testFailedChainedUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        let c = Binding<Int>()
        
        a.value = 10
        c.value = 20
        
        try! Binding.unify(a, b)
        do {
            try Binding.unify(b, c)
            XCTFail()
        } catch { }
    }
    
    func testValueMutation() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        
        a.value = 10
        b.value = 10
        
        try! Binding.unify(a, b)

        b.value = 12
        XCTAssertEqual(a.value, 12)
    }
}
