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
    
    func testBacktracking() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        let c = Binding<Int>()
        let d = Binding<Int>()
        let e = Binding<Int>()
        
        try! Binding.unify(a, b)
        try! Binding.unify(c, d)
        
        do {
            try Binding.attempt(a) {
                try! Binding.unify(a, e)
                try! Binding.unify(a, c)
                throw UnificationError("Test")
            }
            XCTFail()
        } catch {
            a.value = 10
            e.value = 20
            
            XCTAssertEqual(10, a.value)
            XCTAssertEqual(10, b.value)
            XCTAssertEqual(20, c.value)
            XCTAssertEqual(20, d.value)
            XCTAssertEqual(20, e.value)
        }
    }
    
    func testTerm() {
        let a = Term.Constant(10)
        let b = Term.Variable(Binding<Int>())
        let c = Term.Constant(12)

        try! Term.unify(a, b)
        XCTAssertEqual(10, b.value)
        
        try! Term.unify(a, a)
        do {
            try Term.unify(a, c)
            XCTFail()
        } catch { }
    }
    
    func testRecursiveUnificaiton() {
        let a = Term.Constant(Term.Variable(Binding<Int>()))
        let b = Term.Constant(Term.Constant(10))
        
        try! Term.unify(a, b)
        XCTAssertEqual(10, b.value?.value)
    }
    
    func testRecursiveBacktracking() {
        let a = Term.Constant(Term.Variable(Binding<Int>()))
        let b = Term.Constant(Term.Constant(10))
        let c = Term.Constant(Term.Constant(20))
        let d = Term.Constant(Term.Variable(Binding<Int>()))
        
        try! Term.unify(a, b)
        do {
            try Term.attempt(a) {
                try Term.unify(b, c)
            }
        } catch {
            try! Term.unify(a, d)
        }
        XCTAssertEqual(10, d.value?.value)
    }
}
