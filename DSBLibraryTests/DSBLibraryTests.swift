//
//  DSBLibraryTests.swift
//  DSBLibraryTests
//
//  Created by Nils Bergmann on 03.09.17.
//  Copyright © 2017 Noim. All rights reserved.
//

import XCTest
import PromiseKit
@testable import DSBLibrary

class DSBLibraryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let exp: XCTestExpectation = expectation(description: "Login");
        
        let dsb: DSB = DSB(with: "277162", and: "PlanMCG", and: nil);
        dsb.login().then {cookies -> Void in
            print("Finished, cookies: \(cookies)");
            exp.fulfill();
        }.catch {error -> Void in
            print(error);
            XCTFail("An error occurred: \(error)");
        };
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}
