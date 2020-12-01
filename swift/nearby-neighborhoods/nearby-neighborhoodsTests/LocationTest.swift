//
//  nearby_neighborhoodsTests.swift
//  nearby-neighborhoodsTests
//

import XCTest
@testable import nearby_neighborhoods

class LocationTest : XCTestCase {
    
  func testDistanceTo() {
    let sf = Location(latitude: 37.7577627,longitude: -122.4727051)
    let nyc = Location(latitude: 40.6976633,longitude: -74.1201054)
    XCTAssertEqual(4125, sf.distance(toLocation: nyc), accuracy: 1.0)
//    XCTAssertEqual(4125, sf.haversinDistance(toLocation: nyc), accuracy: 1.0)
//    XCTAssertEqual(4125, sf.trigADistance(toLocation: nyc), accuracy: 1.0)
//    XCTAssertEqual(4125, sf.trigBDistance(toLocation: nyc), accuracy: 1.0)
//    XCTAssertEqual(4125, sf.vectorDistance(toLocation: nyc), accuracy: 1.0)
  }
    
}
