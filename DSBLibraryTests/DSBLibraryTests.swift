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
        
        let dsb: DSB = DSB(with: "277162", and: "PlanMCG", and: nil, enableDebug: nil);
        dsb.login().then {cookies -> Void in
            print("Finished, cookies: \(cookies)");
            exp.fulfill();
        }.catch {error -> Void in
            print(error);
            XCTFail("An error occurred: \(error)");
        };
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    //func testDecode() {
    //    let data: String = "H4sIAAAAAAAEAO1b3Y6jNhS+r9R3iHLVSusEDBiYu1WqVqPOrFabuauqlY2PEzoEomB2W43mbfZN9sXWxBMSEmBINjNLmuQm0fHx+fn8cWzg5OHnn3q9/gdIs0gGCYf+Vc94syEbSyqz9DoWiRrp9/WQEi7kdczhXyVE5qb+LcTZtYRZqkb+yuW93oP+UiqrKdqDFgVJfBPG92vrS/FdKKM8FjVlSiMJG0OjaRjxDfMlFyU35puyeMPVVMp5ejUc0vl8wFOmRuQiiQYchqlKOAyGNOaLJOShGkmHd2EE6WAeT/pli0WUb7N0+vVLPIEthQ9JItV4Kbw8El5O90n8G5VQOVD42Z0CkoZR9SQ6SSsHRkl8998cSuvwNPR+ESZV8t2Fa1gM/XnYFhR5W57LWWC5SFgBINulGDE7wMiyCTCwMWeGsR10CR/THRjeABum2zPxleVVKheY3Y7+QDfJJKk2WYtfI4ZbOOKq4RosNRA1eGq7tZjmnwpctcnvwlaDsQe+Gp42GGvTBc71Vx6nkg6ZzS0PWIAcB1QCBAvkOYGDCMXgsSDAQljDNlm2UvpoGMbgn/mkPsMGAujFKkhg16k0EEGvXAMZtI+CEH/X+4BPIXzOQ/1BCFYF9rgrrMpgM/odO487E+orC2fU8X1mIt8jLE/dRb5FCWIBEwEXBFMiGiuLYQ4Mv2C+TZ6vLONgmkX3EYQ8294eVrb/ZyXmUJA1GHsAreHZC2zt46i1pk26rZTOttYcH8HKWlMZ7oXKL7QQZmeobJ4olc0LlbtBZdwZKldt8tpHt6mML1TuBpWtzlDZOlEqWxcqd4PKdmeoXGug41S2L1TuBpWdzlDZOVEqOxcqd4PKpDNUJidKZXKhcjeo7HaGyu6JUtntzIN/JoTgHjOQTQ2MFA4U+Yz7yOQGASfgnhDVz/KLS8BaXwLkynnmleJ4DmEK84jGvREVIGER0t4v5q9n8fz/UKw1GHvgreE5BHPt6qiVp03WrZTO9jXA8RF8scpTFmzPr51brli1GPZvQU4T/o7OlsSWeXPJVt/IO/g8SrJY7ixRf0w/wQ1Nl305+XS5yGCtsBlBdU/Mlrnv6YmZqQuMRdDUF/M++volvjTFFJ/6HczAlHoAHmLEpcj2OCBKwUC+TznFlu/agPfYwWy/eQf7M6JpCnFvCpmEs9i2DgVYg7EHyBqeFdBpxlK5fNszlbNX2qvapNpKqTHmPfap2nu1Lu5TrdCba6PL2teFA7BtgQCCLYRt4qjN03EQA9tFLrEMO6CcOYS9QPmYJYsJxGdRPw5FWINxUvWjTaqtlM6yfrRC71XqxysfY5/Og8c6yq5+rr1uedzoCa900uBgleJua/q6m+TZ1vSxOgbLcLJ5eN+jOf1oB/HfATijwX3TOXyl0z9oaUX17PYrK2iU7nWXcrTO/bcsyWQTMst/NhyECs1Nvx4k+FiQ5H3azZhojcNQiarmHg7LixaB/EsbVtnROIaodAvYv1W40Vg+PfZixBQcGPKwp8o6xo76ZQgELgTgE8vhNFBl9PEbEnQPS1EzAAA=";
    //    let dsb: DSB = DSB(with: "277162", and: "PlanMCG", and: nil, enableDebug: nil);
    //    print(try! dsb.decodeDSBData(data: data));
    //}
    
    //func testEncodeAndDecode() {
    //    let input: String = "This is a test.";
    //    print("Input: \(input)");
    //    let dsb: DSB = DSB(with: "277162", and: "PlanMCG", and: nil, enableDebug: nil);
    //    let compressed: String = try! dsb.encodeDSBData(data: input);
    //    print("Compressed Output: \(compressed)");
    //    let output: String = try! dsb.decodeDSBData(data: compressed);
    //    print("Output: \(output)");
    //}
    
    func testFetch() {
        let exp: XCTestExpectation = expectation(description: "Fetch");
        
        let dsb: DSB = DSB(with: "277162", and: "PlanMCG", and: nil, enableDebug: nil);
        dsb.login().then {_ in
            return dsb.fetch();
        }.then {response -> Void in
            print("Response: \(response)");
            exp.fulfill();
        }.catch { error -> Void in
            XCTFail("An error occurred: \(error)")
        };
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFetchWithoutLogin() {
        let exp: XCTestExpectation = expectation(description: "Fetch without Login");
        
        let dsb: DSB = DSB(with: "277162", and: "PlanMCG", and: nil, enableDebug: nil);
        
        dsb.fetch().then { response -> Promise<String> in
            print("Response 1: \(response)");
            return dsb.fetch();
        }.then {response -> Void in
            print("Response 2: \(response)");
            exp.fulfill();
        }.catch { error -> Void in
            XCTFail("An error occurred: \(error)")
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSmartFetch() {
        let exp: XCTestExpectation = expectation(description: "Smart fetch");
        
        let dsb: DSB = DSB(with: "277162", and: "PlanMCG", and: nil, enableDebug: nil);
        
        dsb.login().then { _ in
            return dsb.smartFetch();
        }.then {response -> Void in
            print("Smart fetch response: \(response)");
            exp.fulfill();
        }.catch {error -> Void in
            XCTFail(error.localizedDescription);
        };
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSmartFetchWithoutLogin() {
        let exp: XCTestExpectation = expectation(description: "Smart fetch");
        
        let dsb: DSB = DSB(with: "277162", and: "PlanMCG", and: nil, enableDebug: nil);
        
        let fakeCookies: [HTTPCookie] = [HTTPCookie(), HTTPCookie()]
        dsb.sessionCookies = fakeCookies;
        
        dsb.smartFetch().then {response -> Void in
            print("Smart fetch response: \(response)");
            exp.fulfill();
        }.catch {error -> Void in
            XCTFail(error.localizedDescription);
        };
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetData() {
        let exp: XCTestExpectation = expectation(description: "");
        
        let dsb: DSB = DSB(with: "277162", and: "PlanMCG", and: nil, enableDebug: false);
        
        dsb.smartFetch().then {response -> Void in
            print("Got result. Try getData()");
            if let tiles = dsb.getData(from: response, methodName: "tiles") {
                print("tiles: \(tiles)");
            }
            if let news = dsb.getData(from: response, methodName: "news") {
                print("news: \(news)");
            }
            if let timetables = dsb.getData(from: response, methodName: "timetable") {
                print("timetables: \(timetables)");
            }
            exp.fulfill();
        }.catch {error -> Void in
            XCTFail(error.localizedDescription);
        }
        
        waitForExpectations(timeout: 10, handler: nil);
    }
}
