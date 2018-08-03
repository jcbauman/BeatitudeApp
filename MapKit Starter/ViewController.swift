//
//  ViewController.swift
//  Beatitude
//
//  Created by Rocko Bauman
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet var mapView: MKMapView?
    @IBOutlet weak var addSong: UIButton!
    @IBOutlet weak var deleteZone: UIButton!
    @IBOutlet weak var centerMap: UIButton!
    @IBOutlet weak var centerPin: UIImage!
    @IBOutlet weak var radiusSlider: UISlider!
    
    let locationManager = CLLocationManager()
    var mapCenterLongitude = 0.0
    var mapCenterLatitude = 0.0
    
    var places = Place.getPlaces()
    
    //CoreData
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        
        //populate map
        super.viewDidLoad()
        requestLocationAccess()
        viewDidAppear()
    }
    
    func viewDidAppear(){
        super.viewDidAppear(true)
        print("viewDidApp!")
        //clear and reload zones
        self.mapView?.removeAnnotations((self.mapView?.annotations)!)
        let overlays = self.mapView?.overlays
        self.mapView?.removeOverlays(overlays!)
        
        places = Place.getPlaces()
        addAnnotations()
        
        //UI button/navBar elements
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.red,
             NSFontAttributeName: UIFont(name: "Futura", size: 20)!]
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
    
    //zoom in on user on button press
    @IBAction func centerMapPressed(_ sender: UIButton) {
        zoomIn(self)
    }
    
    //add song-linked zone to core data
    @IBAction func saveSongPressed(_ sender: UIButton) {
        
        mapCenterLongitude = (mapView?.centerCoordinate.longitude)!
        mapCenterLatitude = (mapView?.centerCoordinate.latitude)!
    }
    
    func addAnnotations(){
        mapView?.delegate = self
        mapView?.addAnnotations(places)
        
        let overlays = places.map { MKCircle(center: $0.coordinate, radius: $0.radius! )}
        mapView?.addOverlays(overlays)
    }
    
    //zoom in on user's location
    func zoomIn(_ sender: Any?){
        let userLocation = mapView?.userLocation
        let region = MKCoordinateRegionMakeWithDistance((userLocation?.location?.coordinate)!, 500, 500)
        mapView?.setRegion(region, animated: true)
        
    }
    
    //opening location
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            let span = MKCoordinateSpanMake(0.05, 0.05)
//            let region = MKCoordinateRegion(center: location.coordinate, span: span)
//            mapView?.setRegion(region, animated: true)
//        }
//    }
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
    
    //overlay UI elements
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.black.withAlphaComponent(0.1)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 2
        return renderer
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: UIButton) {
        if segue.identifier == "searchSpotifySegue" {
            let destinationVC : SearchTableViewController = segue.destination as! SearchTableViewController
            destinationVC.mapCenterLongitude = (mapView?.centerCoordinate.longitude)!
            print("set longitude")
            destinationVC.mapCenterLatitude = (mapView?.centerCoordinate.latitude)!
        }
        //clear and reload zones
        self.mapView?.removeAnnotations((self.mapView?.annotations)!)
        let overlays = self.mapView?.overlays
        self.mapView?.removeOverlays(overlays!)
        places = Place.getPlaces()
        addAnnotations()
    }
}

