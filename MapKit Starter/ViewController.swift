//
//  ViewController.swift
//  MapKit Starter
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet var mapView: MKMapView?
    @IBOutlet weak var addSong: UIButton!
    @IBOutlet weak var deleteZone: UIButton!
    @IBOutlet weak var centerMap: UIButton!
    
    let locationManager = CLLocationManager()
    
    let places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationAccess()
        addAnnotations()
        //zoomIn(self)
        
        //corner rounding
        addSong.layer.cornerRadius = 10;
        addSong.clipsToBounds = true;
        deleteZone.layer.cornerRadius = 10;
        deleteZone.clipsToBounds = true;
    }
    
    //get the user to confirm location access
    func requestLocationAccess(){
        let status = CLLocationManager.authorizationStatus()
        switch status{
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .denied, .restricted:
            print("location access denied, what gives!")
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func centerMapPressed(_ sender: UIButton!) {
        zoomIn(self)
    }
    
    func addAnnotations(){
        mapView?.delegate = self
        mapView?.addAnnotations(places)
        
        let overlays = places.map { MKCircle(center: $0.coordinate, radius: $0.radius! )}
        mapView?.addOverlays(overlays)
    }
    
    func zoomIn(_ sender: Any?){
        let userLocation = mapView?.userLocation
        let region = MKCoordinateRegionMakeWithDistance((userLocation?.location?.coordinate)!, 500, 500)
        mapView?.setRegion(region, animated: false)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView?.setRegion(region, animated: true)
        }
    }
    
}

//dequeue and display annotations if they are not the user's annotation
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "place icon")
            return annotationView
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.black.withAlphaComponent(0.1)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 2
        return renderer
    }
}

