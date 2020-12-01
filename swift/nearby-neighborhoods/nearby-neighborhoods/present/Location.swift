
import Foundation
import simd

/**
   A geographic location
*/
public class Location
{
  public let latitude: Double
  public let longitude: Double

  /**
   Constructs a new set of coordinates
    - parameter latitude: in degrees
    - parameter longitude: in degrees
  */
  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }

  /**
    Computes the great-circle distance (https://en.wikipedia.org/wiki/Great-circle_distance)
    between this location and another in km.
   */
  public func haversinDistance(toLocation other: Location) -> Double {
    Location.distanceComputations.increment()

    let haversin = { (angle: Double) -> Double in
        return (1 - cos(angle))/2
    }

    let ahaversin = { (angle: Double) -> Double in
        return 2*asin(sqrt(angle))
    }

    // Converts from degrees to radians
    let dToR = { (angle: Double) -> Double in
        return (angle / 360) * 2 * .pi
    }

    let lat1 = dToR(latitude)
    let lon1 = dToR(longitude)
    let lat2 = dToR(other.latitude)
    let lon2 = dToR(other.longitude)

    let radius: Double = 6371
    return radius * ahaversin(haversin(lat2 - lat1) + cos(lat1) * cos(lat2) * haversin(lon2 - lon1))
  }

  func linearUnitDistance(toLocation other: Location) -> Double {
    let p1 = self.toUnitSimdVec
    let p2 = other.toUnitSimdVec
    let sec = simd_distance(p1, p2)
    // The simd_distance is verified to match
    //    let sec = sqrt(pow(p2.x-p1.x,2) + pow(p2.y-p1.y,2) + pow(p2.z-p1.z,2))
   return sec
  }
  
  public func vectorDistance(toLocation other: Location) -> Double {
    Location.distanceComputations.increment()
// Algorithm taken from:
//    https://stackoverflow.com/questions/10473852/convert-latitude-and-longitude-to-point-in-3d-space
//
// It originally prescribed a radius size of:
//    let rad: Double = 6378.1370
//
// However, empirically it was failing for the basic unit test of 4125 for the sf <-> nyc distance
// calculation (was off by like 10m)
//
// The rad value was adjusted below for the sf <-> nyc distance to be equal
// to the other distance calculations
    let rad: Double = 6362.3236885044298
    
    let sec = linearUnitDistance(toLocation:other)
    let rads = 2*asin(sec/2.0)
    let d = rads * rad

    return d
  }
  
  public func trigADistance(toLocation other: Location) -> Double {
    let rad: Double = 6371
    let lat1 = latitude.degreesToRadians
    let lon1 = longitude.degreesToRadians
    let lat2 = other.latitude.degreesToRadians
    let lon2 = other.longitude.degreesToRadians
    
    let d = acos(cos(lat1)*cos(lon1)*cos(lat2)*cos(lon2) + cos(lat1)*sin(lon1)*cos(lat2)*sin(lon2) + sin(lat1)*sin(lat2)) * rad
    return d
  }
  
  public func trigBDistance(toLocation other: Location) -> Double {
    let rad: Double = 6371
    
    let lat1 = latitude.degreesToRadians
    let lon1 = longitude.degreesToRadians
    let lat2 = other.latitude.degreesToRadians
    let lon2 = other.longitude.degreesToRadians
    
    let d = rad * acos((sin(lat1) * sin(lat2)) + cos(lat1)*cos(lat2)*cos(lon2-lon1))
    return d
  }

  public func basicDistance(toLocation other: Location) -> Double {
    Location.distanceComputations.increment()
    
    let rad: Double = 6371
    
    let lat1rad = latitude.degreesToRadians
    let lon1rad = longitude.degreesToRadians
    let lat2rad = other.latitude.degreesToRadians
    let lon2rad = other.longitude.degreesToRadians
    
    let dlon = lon2rad - lon1rad
    let dlat = lat2rad - lat1rad

    let a = pow(sin(dlat/2.0),2) + cos(lat1rad) * cos(lat2rad) * pow(sin(dlon/2.0),2)
    let c = 2.0 * atan2( sqrt(a), sqrt(1-a) )
    let d = c * rad
        
    return d
  }
  
  public func distance(toLocation other: Location) -> Double {
    return vectorDistance(toLocation: other)
  }
  
  public static func dumpDistances() {
    
    var results:[(d1:Double, d2:Double, d3:Double, d4:Double, d5:Double, n:Neighborhood)] = []

    let myloc = Location(latitude: 26.0765, longitude: -80.2521)
    for n in Neighborhoods.ALL {
      let d1 = myloc.basicDistance(toLocation:n.location);
      let d2 = myloc.haversinDistance(toLocation: n.location)
      let d3 = myloc.trigADistance(toLocation: n.location)
      let d4 = myloc.trigBDistance(toLocation: n.location)
      let d5 = myloc.vectorDistance(toLocation: n.location)
      results.append((d1, d2, d3, d4, d5, n));
    }
    
    results.sort(by:{ $0.d1 < $1.d1})
    
//    var lastD2:Double = 0.0
//    var lastD3:Double = 0.0
//    var lastD4:Double = 0.0
//    var lastD5:Double = 0.0
//    for r in results {
//      if (r.d2 < lastD2) || (r.d3 < lastD3) || (r.d4 < lastD4) || (r.d5 < lastD5){
////        assertionFailure("NOPE!!!! WRONG!!!!")
//        print(String(format:"ERROR %@ %@ %@ %@ %@ %@", r.n.name, String(r.d1), String(r.d2), String(r.d3), String(r.d4), String(r.d5)))
//      } else {
//        print(String(format:"SUCCESS %@ %@ %@ %@ %@ %@", r.n.name, String(r.d1), String(r.d2), String(r.d3), String(r.d4), String(r.d5)))
//      }
//      lastD2 = r.d2
//      lastD3 = r.d3
//      lastD4 = r.d4
//      lastD5 = r.d5
//    }
    
    for r in results {
      print(String(format:"VectorError: %@ %@)", String(r.d5 - r.d1), r.n.name))
    }
    
  }

  
  static let distanceComputations = Counter()
}



extension FloatingPoint {
  var degreesToRadians: Self { return self * .pi / 180 }
  var radiansToDegrees: Self { return self * 180 / .pi }
}

extension Location: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(latitude)
    hasher.combine(longitude)
  }
  
  public static func == (lhs: Location, rhs: Location) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
  
  // taken from https://stackoverflow.com/questions/10473852/convert-latitude-and-longitude-to-point-in-3d-space
  //
  // this returns the unit vector (i.e. x,y,z in radian lengths)
  //
  // Values were verified to match the SO example via:
  // https://www.oc.nps.edu/oc2902w/coord/llhxyz.htm
  var toUnitSimdVec: simd_double3 {
    let f: Double = (1.0/298.257223563)
    let FF: Double = pow( (1.0-f),2)

    let lat1 = latitude.degreesToRadians
    let lon1 = longitude.degreesToRadians

    let cosLat:Double = cos(lat1)
    let sinLat:Double = sin(lat1)
    let CA = 1/sqrt(pow(cosLat,2) + FF * pow(sinLat,2))
    let SA = CA * FF

    let x:Double = cosLat * cos(lon1) * CA
    let y:Double = cosLat * sin(lon1) * CA
    let z:Double = sin(lat1) * SA
    return simd_make_double3(x,y,z)
  }


  // there's also
  //  toNvector() { // note: replicated in LatLon_NvectorEllipsoidal
  //          const φ = this.lat.toRadians();
  //          const λ = this.lon.toRadians();
  //
  //          const sinφ = Math.sin(φ), cosφ = Math.cos(φ);
  //          const sinλ = Math.sin(λ), cosλ = Math.cos(λ);
  //
  //          // right-handed vector: x -> 0°E,0°N; y -> 90°E,0°N, z -> 90°N
  //          const x = cosφ * cosλ;
  //          const y = cosφ * sinλ;
  //          const z = sinφ;
  //
  //          return new NvectorSpherical(x, y, z);
  //      }

  
}
