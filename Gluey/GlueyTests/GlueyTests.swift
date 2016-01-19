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
        
        try! unify(a, b)
        a.value = 10
        XCTAssertEqual(10, b.value)
    }
    
    func testUnificationWithEagerValueSet() {
        let a = Binding<Int>()
        a.value = 10
        let b = Binding<Int>()
        
        try! unify(a, b)
        XCTAssertEqual(10, b.value)
    }
    
    func testChainedUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        let c = Binding<Int>()
        
        try! unify(a, b)
        try! unify(b, c)
        c.value = 10
        
        XCTAssertEqual(a.value, 10)
        XCTAssertEqual(b.value, 10)
    }
    
    func testSuccessfulUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        
        a.value = 10
        b.value = 10
        
        try! unify(a, b)
    }
    
    func testSuccessfulChainedUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        let c = Binding<Int>()
        
        a.value = 10
        c.value = 10
        
        try! unify(a, b)
        try! unify(b, c)
    }
    
    func testFailedUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        
        a.value = 10
        b.value = 20
        
        do {
            try unify(a, b)
            XCTFail()
        } catch { }
    }
    
    func testFailedChainedUnification() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        let c = Binding<Int>()
        
        a.value = 10
        c.value = 20
        
        try! unify(a, b)
        do {
            try unify(b, c)
            XCTFail()
        } catch { }
    }
    
    func testValueMutation() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        
        a.value = 10
        b.value = 10
        
        try! unify(a, b)

        b.value = 12
        XCTAssertEqual(a.value, 12)
    }
    
    func testBacktracking() {
        let a = Binding<Int>()
        let b = Binding<Int>()
        let c = Binding<Int>()
        let d = Binding<Int>()
        let e = Binding<Int>()
        
        try! unify(a, b)
        try! unify(c, d)
        
        do {
            try a.attempt {
                try! unify(a, e)
                try! unify(a, c)
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

        try! unify(a, b)
        XCTAssertEqual(10, b.value)
        
        try! unify(a, a)
        do {
            try unify(a, c)
            XCTFail()
        } catch { }
    }
    
    func testRecursiveUnificaiton() {
        let a = Term.Constant(Term.Variable(Binding<Int>()))
        let b = Term.Constant(Term.Constant(10))
        
        try! unify(a, b)
        XCTAssertEqual(10, b.value?.value)
    }
}
