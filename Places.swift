//
//  Places.swift
//  MapKit Starter
//

import CoreData
import MapKit
extension Place: MKAnnotation {}

@objc class Place: NSObject {
    var song: String?
    var songURI: String?
    var radius: Double?
    var coordinate: CLLocationCoordinate2D
    var imageURL: String?
    
    init(song: String?, songURI: String?, coordinate: CLLocationCoordinate2D, radius: Double, imageURL: String) {
        self.song = song
        self.songURI = songURI
        self.coordinate = coordinate
        self.radius = radius
        self.imageURL = imageURL
    }
    
    static func getPlaces() -> [Place] {
        
        //CORE DATA TIME vvv
       
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Zones")
        request.returnsObjectsAsFaults = false
        
        var array:[Zones] = []
        
        do{
            array = try context.fetch(Zones.fetchRequest())
        }catch{
            print(error)
        }
        
        var places = [Place]()
        
        for item in array{
            let song = item.song!
            let songURI = item.songURI!
            let latitude = item.latitude!, longitude = item.longitude!
            let radius = item.radius!
            let imageURL = item.imageURL!
            
            let place = Place(song: song, songURI: songURI, coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude)), radius: Double(radius), imageURL: imageURL)
            places.append(place)
        }
        return places as [Place]
    }
}
