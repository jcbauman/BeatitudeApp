//
//  MainViewController.swift
//  Beatitude
//
//  Created by Rocko Bauman on 8/2/18.
//  Copyright © 2018 Rocko Bauman. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

class MainViewController: UIViewController, CLLocationManagerDelegate {

    var currentSong = URL(string:"spotify.com")
    @IBOutlet weak var playButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let locationManager: CLLocationManager = CLLocationManager()
    var places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
//        let newZone = NSEntityDescription.insertNewObject(forEntityName: "Zones", into: context)
//        newZone.setValue("https://open.spotify.com/track/4Qt3qAKiQW0aP4HcpaWlNl?si=c-kLkCiqS9ufDhhyjdnoWQ", forKey: "songURI")
//        newZone.setValue("Future Shock", forKey: "song")
//        newZone.setValue(37.773467, forKey: "latitude")
//        newZone.setValue(-122.417919, forKey: "longitude")
//        newZone.setValue("f.com", forKey: "imageURL")
//        newZone.setValue(100, forKey: "radius")
        
        do {
            try context.save()
            print("saved")
        }
        catch{
            print("couldn't save context, error bro!")
        }
        
        //UI
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.red,
             NSFontAttributeName: UIFont(name: "Futura", size: 20)!]
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations{
            print("\(index): \(locations)")
            places = Place.getPlaces()
            for zone in places{
                let pinLocationLat = zone.coordinate.latitude
                print(pinLocationLat)
                let pinLocationLong = zone.coordinate.longitude
                print(pinLocationLong)
                let pinLoc = CLLocation(latitude: pinLocationLat, longitude: pinLocationLong)
                let distance : CLLocationDistance = pinLoc.distance(from: currentLocation)
                let distanceDoub = Double(distance)
                print(distanceDoub)
                print(zone.radius!)
                if(distanceDoub <= zone.radius!){
                    //play this song
                    let nextSong = URL(string: zone.songURI!)!
                    if nextSong != currentSong{
                        print("PLAYING SONG")
                        currentSong = nextSong
                        UIApplication.shared.open(currentSong!, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
