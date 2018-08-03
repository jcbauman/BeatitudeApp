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
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
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
            for currentLocation in locations{
                places = Place.getPlaces()
                for zone in places{
                    let pinLocationLat = zone.coordinate.latitude
                    let pinLocationLong = zone.coordinate.longitude
                    let pinLoc = CLLocation(latitude: pinLocationLat, longitude: pinLocationLong)
                    let distance : CLLocationDistance = pinLoc.distance(from: currentLocation)
                    let distanceDoub = Double(distance)
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
    }
    
    @IBAction func pausePlayPressed(_ sender: Any) {
        if playButton.titleLabel?.text! == "PAUSE" {
            playButton.setTitle("PLAY", for: .normal)
            do{
                player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Pop", ofType: "aiff")!))
                player.prepareToPlay()
                player.play()
            }catch{
                print(error)
            }
        }else {
            playButton.setTitle("PAUSE", for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
