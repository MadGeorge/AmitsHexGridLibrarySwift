//
//  AmitsHexGridTests.swift
//  AmitsHexGridTests
//
//  Created by MadGeorge on 10/01/2017.
//  Copyright © 2017 MadGeorge. All rights reserved.
//

import XCTest
@testable import AmitsHexGrid

class AmitsHexGridTests: XCTestCase {
    let hex1 = try! Hex(q:  1,  r: 2,  s: -3)
    let hex2 = try! Hex(q:  1,  r: 2,  s: -3)
    let hex3 = try! Hex(q: -1,  r: -3, s:  4)
    
    func testHexShouldImplementEquatable() {
        XCTAssertTrue(hex1 == hex2)
        XCTAssertTrue(hex2 != hex3)
        XCTAssertFalse(hex1 == hex3)
    }

    func testHexCoordinateArithmetic() {
        let add = hex1.add(hex: hex1)
        XCTAssertEqual(add, try! Hex(q: 2, r: 4, s: -6))
        
        let subtract = hex1.subtract(hex: hex1)
        XCTAssertEqual(subtract, try! Hex(q: 0, r: 0, s: 0))
        
        let multiply = hex1.multiply(by: 2)
        XCTAssertEqual(multiply, try! Hex(q: 2, r: 4, s: -6))
    }

    func testHexDistanceArithmetic() {
        XCTAssertEqual(hex1.length, 3)
        XCTAssertEqual(hex1.distance(to: hex3), 7)
    }
    
    func testHexNeighborsArithmetic() {
        XCTAssertEqual(hex1.direction(at: 1), try! Hex(q:  1,  r: -1,  s:  0))
        XCTAssertEqual(hex1.neighbor(at: 1), try! Hex(q:  2,  r: 1,  s:  -3))
    }
}
