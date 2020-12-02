//
//  ViewController.swift
//  nearby-neighborhoods
//
//  Created by Patrick Niemeyer on 9/14/17.
//  Copyright © 2017 co.present. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    let mapView = MKMapView()
    var pins = [(neighborhood:Neighborhood, annotation:MKPointAnnotation)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.frame = self.view.frame
        mapView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        view.addSubview(mapView)
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayedNeighborhoods()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeAnnotations() {
        // TODO: can do this better - just making it work for now
        let annotations = pins.map({$0.annotation})
        mapView.removeAnnotations(annotations)
    }
    
    func updateDisplayedNeighborhoods() {
        self.removeAnnotations()

        let mapCenter = mapView.centerCoordinate
        let searchLocation = Location(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
        let neighborhoods = IndexedNeighborhoods.near(location: searchLocation, n: 5)
        for neighborhood in neighborhoods {
            print (" - \(neighborhood.name)")
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(neighborhood.location.latitude, neighborhood.location.longitude)
            mapView.addAnnotation(annotation)
            pins.append((neighborhood,annotation))
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateDisplayedNeighborhoods()
    }
}
