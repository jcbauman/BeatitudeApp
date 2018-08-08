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
    @IBOutlet var infoBox: UIImageView!
    @IBOutlet weak var centerCircle: UIImageView!
    
    
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
        addAnnotations()
        
        //UI button/navBar elements
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.red,
             NSFontAttributeName: UIFont(name: "Futura", size: 20)!]
        addSong.layer.cornerRadius = 10;
        addSong.clipsToBounds = true;
        deleteZone.layer.cornerRadius = 10;
        deleteZone.clipsToBounds = true;
        centerMap.layer.cornerRadius = 10;
        centerMap.clipsToBounds = true
        let infoButton = UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(showInfo))
        self.navigationItem.rightBarButtonItem = infoButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor.yellow
        navigationItem.leftBarButtonItem?.tintColor = UIColor.yellow
        centerCircle.isHidden = true
        centerCircle.alpha = 1
        
        //setup Notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMapAnn(_:)), name: Notification.Name(rawValue: "reloadMapAnnotations"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(justAddedNewZoner(_:)), name: Notification.Name(rawValue: "justAddedNewZone"), object: nil)
        
        //infobox tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissInfo))
        infoBox.addGestureRecognizer(tapRecognizer)
        
        //center circle guide recognizer
        let mapTapRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(showCircleGuide))
            self.mapView?.addGestureRecognizer(mapTapRecognizer)
        }
    
    func viewWillAppear(){
        super.viewWillAppear(true)
        addAnnotations()
        zoomIn(self)
        centerCircle.isHidden = true
    }
    
    //show help info box
    @objc func showInfo(){
       self.view.addSubview(infoBox)
        infoBox.center = self.view.center
        infoBox.alpha = 0
        infoBox.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        UIImageView.animate(withDuration: 0.5){
            self.infoBox.alpha = 1
            self.infoBox.transform = CGAffineTransform.identity
        }
    }
    
    //hide help info box
    func dismissInfo(recognizer: UITapGestureRecognizer) {
        UIImageView.animate(withDuration: 0.3, animations: {
            self.infoBox.alpha = 0
            self.infoBox.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        }){(success: Bool) in
            self.infoBox.removeFromSuperview()
        }
    }
    
    //show and hide circle guide
    func showCircleGuide(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            print("pinching")
            centerCircle.isHidden = false
            //centerCircle.alpha = 0
           // UIImageView.animate(withDuration: 0.5){
           //     self.centerCircle.alpha = 1
          //  }
        } else if recognizer.state == .ended{
            print("stopped pinching")
            centerCircle.isHidden = true
        }
    }
    
    //reload map annotations
    @objc func reloadMapAnn(_ notification: Notification) {
        addAnnotations()
    }
    
    //reload map annotations and animate map
    @objc func justAddedNewZoner(_ notification: Notification) {
        addAnnotations()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let span = MKCoordinateSpan(latitudeDelta: (self.mapView?.region.span.latitudeDelta)! * 1.2, longitudeDelta: (self.mapView?.region.span.longitudeDelta)! * 1.2)
            let region = MKCoordinateRegion(center: (self.mapView?.region.center)!, span: span)
            
            self.mapView?.setRegion(region, animated: true)
        }
    }
    
    //get the user to confirm location access
    func requestLocationAccess(){
        let status = CLLocationManager.authorizationStatus()
        switch status{
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .denied, .restricted:
            //if location access is denied
            let alertController = UIAlertController (title: "Please Allow Location Updates", message: "You are not able to experience location-based music without letting Beatitude access your current location.", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
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
    
    //clear and reload zones annotations
    func addAnnotations(){
        self.mapView?.removeAnnotations((self.mapView?.annotations)!)
        let overlays = self.mapView?.overlays
        self.mapView?.removeOverlays(overlays!)
        
        places = Place.getPlaces()
        mapView?.delegate = self
        mapView?.addAnnotations(places)
        
        let newOverlays = places.map { MKCircle(center: $0.coordinate, radius: $0.radius! )}
        mapView?.addOverlays(newOverlays)
    }
    
    //zoom in on user's location
    func zoomIn(_ sender: Any?){
        requestLocationAccess()
        let userLocation = mapView?.userLocation
        if userLocation == nil{
            let alert = UIAlertController(title: "Beatitude can't find your location", message: "Make sure location services are enabled and you're in an area where location updates are possible.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)

        }
        else{
            let region = MKCoordinateRegionMakeWithDistance((userLocation?.location?.coordinate)!, 500, 500)
            mapView?.setRegion(region, animated: true)
        }
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
            annotationView.image = UIImage(named: "zone_logo")
            return annotationView
        }
    }
    
    //zone overlay UI elements
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.black.withAlphaComponent(0.1)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 2
        return renderer
    }
    
    //transition to Spotify search with "Add Song"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchSpotifySegue" {
            let destinationVC : SearchTableViewController = segue.destination as! SearchTableViewController
            destinationVC.mapCenterLongitude = (mapView?.centerCoordinate.longitude)!
            destinationVC.mapCenterLatitude = (mapView?.centerCoordinate.latitude)!
            let mapSpan = (mapView?.region.span.longitudeDelta)!
            print(mapSpan)
            destinationVC.mapSpan = mapSpan
        }
        //clear and reload zones
        self.mapView?.removeAnnotations((self.mapView?.annotations)!)
        let overlays = self.mapView?.overlays
        self.mapView?.removeOverlays(overlays!)
        places = Place.getPlaces()
        addAnnotations()
    }
}

