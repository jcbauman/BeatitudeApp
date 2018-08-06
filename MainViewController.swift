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

    var currentlyInZone = false
    var currentSong = String()
    fileprivate var track: SPTTrack?
    
    var player = AVAudioPlayer()
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var editMap: UIButton!
    @IBOutlet weak var zoneStatus: UILabel!
    

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
        playButton.layer.cornerRadius = 10;
        playButton.clipsToBounds = true;
        editMap.layer.cornerRadius = 10;
        editMap.clipsToBounds = true;
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            var songsInArea = [String]()
            var songTitlesInArea = [String]()
            for currentLocation in locations{
                places = Place.getPlaces()
                for zone in places{
                    let pinLocationLat = zone.coordinate.latitude
                    let pinLocationLong = zone.coordinate.longitude
                    let pinLoc = CLLocation(latitude: pinLocationLat, longitude: pinLocationLong)
                    let distance : CLLocationDistance = pinLoc.distance(from: currentLocation)
                    let distanceDoub = Double(distance)
                    if (distanceDoub <= zone.radius!) {
                        songsInArea.append(zone.songURI!)
                        songTitlesInArea.append(zone.song!)
                    }
                }
                //play last song in list (fixes collision of zones freakout)
                if songsInArea.count > 0{
                    currentlyInZone = true
                    updateZoneStatus(title: songTitlesInArea[songTitlesInArea.count - 1])
                    let lastSongAdded = songsInArea[songsInArea.count - 1]
                    let nextSong = lastSongAdded
                    if nextSong != currentSong && playButton.titleLabel?.text! == "PAUSE"{
                            currentSong = nextSong
                            load(trackString: currentSong)
                            MediaPlayer.shared.playTrack(uri: currentSong)
                           // MediaPlayer.shared.play(track: track!)
                            //updatePlayButton(playing: true)
                    }
                }else{
                    currentlyInZone = false
                    updateZoneStatus(title: "")
                }
            }
    }
    
    private func load(trackString: String) {
        guard LoginManager.shared.isLogged else {return}
        MediaPlayer.shared.loadTrack(url: trackString) {[weak self] (track, error) in
            guard let `self` = self else {return}
            guard let track = track, error == nil else {
                self.showDefaultError()
                return
            }
            print("loaded track")
            self.track = track
            self.title = track.name
        }
    }
    
    func updateZoneStatus(title: String){
        if currentlyInZone == true{
            zoneStatus.text = String("Current zone: " + title)
        }else{
             zoneStatus.text = String("You are not currently in a music zone")
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
                //locationManager.pausesLocationUpdatesAutomatically = true
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
            locationManager.pausesLocationUpdatesAutomatically = false
            print("Start Updating")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    fileprivate func showDefaultError() {
        let alert = UIAlertController(title: "Oops", message: "Something went wrong. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
