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
    
    func testValue() {
        let a = Unifiable.Literal(10)
        let b = Unifiable.Variable(Binding<Int>())
        let c = Unifiable.Literal(12)

        try! Unifiable.unify(a, b)
        XCTAssertEqual(10, b.value)
        
        try! Unifiable.unify(a, a)
        do {
            try Unifiable.unify(a, c)
            XCTFail()
        } catch { }
    }
    
    func testRecursiveUnificaiton() {
        let a = Unifiable.Literal(Unifiable.Variable(Binding<Int>()))
        let b = Unifiable.Literal(Unifiable.Literal(10))
        
        try! Unifiable.unify(a, b)
        XCTAssertEqual(10, b.value?.value)
    }
    
    func testRecursiveBacktracking() {
        let a = Unifiable.Literal(Unifiable.Variable(Binding<Int>()))
        let b = Unifiable.Literal(Unifiable.Literal(10))
        let c = Unifiable.Literal(Unifiable.Literal(20))
        let d = Unifiable.Literal(Unifiable.Variable(Binding<Int>()))
        
        try! Unifiable.unify(a, b)
        do {
            try Unifiable.attempt(a) {
                try Unifiable.unify(b, c)
            }
        } catch {
            try! Unifiable.unify(a, d)
        }
        XCTAssertEqual(10, d.value?.value)
    }
    
    func testCopy() {
        let a = Unifiable.Variable(Binding<Int>())
        let b = Unifiable.Variable(Binding<Int>())
        try! Unifiable.unify(a, b)
        let context = CopyContext()
        let aa = Unifiable.copy(a, withContext: context)
        let bb = Unifiable.copy(b, withContext: context)
        
        try! Unifiable.unify(a, Unifiable.Literal(1))
        XCTAssertEqual(1, b.value)
        XCTAssertEqual(1, a.value)
        XCTAssertEqual(nil, aa.value)
        XCTAssertEqual(nil, bb.value)
        
        try! Unifiable.unify(aa, Unifiable.Literal(2))
        XCTAssertEqual(1, b.value)
        XCTAssertEqual(1, a.value)
        XCTAssertEqual(2, aa.value)
        XCTAssertEqual(2, bb.value)
    }
    
    func testRecursiveCopy() {
        let a = Unifiable.Literal(Unifiable.Variable(Binding<Int>()))
        let b = Unifiable.Literal(Unifiable.Variable(Binding<Int>()))
        try! Unifiable.unify(a, b)
        let context = CopyContext()
        let aa = Unifiable.copy(a, withContext: context)
        let bb = Unifiable.copy(b, withContext: context)
        
        try! Unifiable.unify(a, Unifiable.Literal(Unifiable.Literal(1)))
        XCTAssertEqual(1, b.value!.value)
        XCTAssertEqual(1, a.value!.value)
        XCTAssertEqual(nil, aa.value!.value)
        XCTAssertEqual(nil, bb.value!.value)
        
        try! Unifiable.unify(aa, Unifiable.Literal(Unifiable.Literal(2)))
        XCTAssertEqual(1, b.value!.value)
        XCTAssertEqual(1, a.value!.value)
        XCTAssertEqual(2, aa.value!.value)
        XCTAssertEqual(2, bb.value!.value)
    }
}
