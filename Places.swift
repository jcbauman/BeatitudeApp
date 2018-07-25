//
//  Places.swift
//  MapKit Starter
//


import MapKit
extension Place: MKAnnotation {}

@objc class Place: NSObject {
    var title: String?
    var subtitle: String?
    var radius: Double?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, radius: Double) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.radius = radius
    }
    
    static func getPlaces() -> [Place] {
        guard let path = Bundle.main.path(forResource: "Places", ofType: "plist"), let array = NSArray(contentsOfFile: path) else { return [] }
        
        var places = [Place]()
        
        for item in array {
            let dictionary = item as? [String : Any]
            let title = dictionary?["title"] as? String
            let subtitle = dictionary?["song"] as? String
            let latitude = dictionary?["latitude"] as? Double ?? 0, longitude = dictionary?["longitude"] as? Double ?? 0
            let radius = dictionary?["radius"] as? Double ?? 0
            
            let place = Place(title: title, subtitle: subtitle, coordinate: CLLocationCoordinate2DMake(latitude, longitude), radius: radius)
            places.append(place)
        }
        
        return places as [Place]
    }
}
