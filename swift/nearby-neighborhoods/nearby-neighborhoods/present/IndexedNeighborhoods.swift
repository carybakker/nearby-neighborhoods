//
//  NeighborhoodIndex.swift
//  nearby-neighborhoods
//
//  Created by Cary Bakker on 12/1/20.
//  Copyright © 2020 co.present. All rights reserved.
//

import Foundation
import KDTree
import simd

public class IndexedNeighborhoods
{
  static let uds = Neighborhoods.ALL.map({NeighborhoodDataPoint($0)})
  static let tree: KDTree<NeighborhoodDataPoint> = KDTree(values:uds)
  
  public static func near(location: Location, n: Int) -> [Neighborhood] {
    // create a temp NeighborhoodDataPoint to use for searching nearest b/c
    // KDTree expects search input to be same as stored data points.
    // Might be able to clean it up, but for now, this does the trick
    let hooddp = NeighborhoodDataPoint(Neighborhood(name:"",location:location))
    return tree.nearestK(n, to:hooddp).map({$0.hood})
  }
}
  
public class NeighborhoodDataPoint: KDTreePoint {
  public static func == (lhs: NeighborhoodDataPoint, rhs: NeighborhoodDataPoint) -> Bool {
    return lhs.hood == rhs.hood
  }
  
  public static var dimensions = 3

  private var unitVec: simd_double3
  public var hood: Neighborhood
  
  init(_ neighborhood:Neighborhood) {
    hood = neighborhood
    unitVec = hood.location.toUnitSimdVec
  }

  public func kdDimension(_ dimension: Int) -> Double {
    switch (dimension) {
    case 0: return unitVec.x
    case 1: return unitVec.y
    case 2: return unitVec.z
    default: return 0
    }
  }
  
  public func squaredDistance(to otherPoint: NeighborhoodDataPoint) -> Double {
    return simd_distance(unitVec, otherPoint.unitVec)
  }

}
