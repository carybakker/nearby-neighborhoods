
/**
   Searches Neighborhoods.ALL
*/
public class Search {

  /**
    Finds the {@code n} neighborhoods nearest to the given location.
      - parameter location: to search near
      - parameter n: number of neighborhoods to return
      - returns: the n nearest neighborhoods, ordered nearest to farthest
   */
  public static func nearSlowWay(location: Location, n: Int) -> [Neighborhood] {
    
    var results:[(distance:Double, neighborhood:Neighborhood)] = []
    
    for neighborhood in Neighborhoods.ALL {
      // for nearest comparisons, it's not required to calculate the arc
      // distance estimate, as the arc distance is proportional to the
      // linear (direct) distance, and the direct distance calculation should
      // be quicker... In this case, I'm using linearUnitDistance, where
      // the unit vectors are based on a sphere of radius = 1 to avoid
      // the calculation of actual meters (again unnecessary for
      // comparison purposes).
      let distance = location.linearUnitDistance(toLocation:neighborhood.location)
      let tup = (distance, neighborhood)
      let i = results.insertionIndexOf(tup, isOrderedBefore: { $0.distance < $1.distance})
      results.insert(tup, at:i)
      if results.count > n {
        results.removeLast()
      }
    }
    
    return results.map { $0.neighborhood }
  }


  /**
    Finds the {@code n} neighborhoods nearest to the given location.
      - parameter location: to search near
      - parameter n: number of neighborhoods to return
      - returns: the n nearest neighborhoods, ordered nearest to farthest
   */
  public static func nearFastWay(location: Location, n: Int) -> [Neighborhood] {
    
    var results:[(distance:Double, neighborhood:Neighborhood)] = []
    
    for neighborhood in Neighborhoods.ALL {
      // for nearest comparisons, it's not required to calculate the arc
      // distance estimate, as the arc distance is proportional to the
      // linear (direct) distance, and the direct distance calculation should
      // be quicker... In this case, I'm using linearUnitDistance, where
      // the unit vectors are based on a sphere of radius = 1 to avoid
      // the calculation of actual meters (again unnecessary for
      // comparison purposes).
      let distance = location.linearUnitDistance(toLocation:neighborhood.location)
      let tup = (distance, neighborhood)
      let i = results.insertionIndexOf(tup, isOrderedBefore: { $0.distance < $1.distance})
      results.insert(tup, at:i)
      if results.count > n {
        results.removeLast()
      }
    }
    
    return results.map { $0.neighborhood }
  }

  public static func near(location: Location, n: Int) -> [Neighborhood] {
    return nearFastWay(location:location, n:n)
  }
}

// Binary insertion search taken from:
// https://stackoverflow.com/questions/26678362/how-do-i-insert-an-element-at-the-correct-position-into-a-sorted-array-in-swift
extension Array {
    func insertionIndexOf(_ elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}
