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
import AVFoundation

class MainViewController: UIViewController, CLLocationManagerDelegate {

    var currentSong = URL(string:"spotify.com")
    
    var player = AVAudioPlayer()
    
    @IBOutlet weak var playButton: UIButton!
    

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let locationManager: CLLocationManager = CLLocationManager()
    var places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.setTitle("PLAY", for: .normal)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        print("Start Updating")
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
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
        if playButton.titleLabel?.text! == "PAUSE" {
            var songsInArea = [String]()
            for currentLocation in locations{
                places = Place.getPlaces()
                for zone in places{
                    let pinLocationLat = zone.coordinate.latitude
                    let pinLocationLong = zone.coordinate.longitude
                    let pinLoc = CLLocation(latitude: pinLocationLat, longitude: pinLocationLong)
                    let distance : CLLocationDistance = pinLoc.distance(from: currentLocation)
                    let distanceDoub = Double(distance)
                    if(distanceDoub <= zone.radius!){
                        songsInArea.append(zone.songURI!)
                    }
                }
                //play last song in list (fixes collision of zones freakout)
                if songsInArea.count > 0{
                    let lastSongAdded = songsInArea[songsInArea.count - 1]
                    let nextSong = URL(string: lastSongAdded)!
                    if nextSong != currentSong && playButton.titleLabel?.text! == "PAUSE"{
                            currentSong = nextSong
                            UIApplication.shared.open(currentSong!, options: [:], completionHandler: nil)
                    }
                    
                }
            }
        }
    }
    
    @IBAction func pausePlayPressed(_ sender: Any) {
        if playButton.titleLabel?.text! == "PAUSE" {
            locationManager.stopUpdatingLocation()
            print("Stopped Updating")
            playButton.setTitle("PLAY", for: .normal)
            do{
                //override spotify by playing a popping sound
                player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Pop", ofType: "aiff")!))
                player.prepareToPlay()
                player.play()
                //currentSong = URL(string:"spotify.com")
            }catch{
                print(error)
            }
        }else {
            playButton.setTitle("PAUSE", for: .normal)
            do{
                player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Pop", ofType: "aiff")!))
                player.prepareToPlay()
                player.play()
            }catch{
                print(error)
            }
            locationManager.startUpdatingLocation()
            print("Start Updating")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
