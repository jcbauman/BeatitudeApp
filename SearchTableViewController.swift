//
//  SearchTableViewController.swift
//  Beatitude
//
//  Created by Rocko Bauman on 7/31/18.
//
import UIKit
import SwiftyJSON
import Alamofire
import AVFoundation
import CoreData

var player = AVAudioPlayer()

//display object for song search
struct post{
    let mainImage : UIImage!
    let name: String!
    let previewURL: String!
    let imageURL: String!
}

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var mapCenterLongitude = Double()
    var mapCenterLatitude = Double()
    
    var accessToken = ""
    var searchURL = String()
    var posts = [post]()
    typealias JSONStandard = [String: AnyObject]
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //CoreData initializtion
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //when search bar triggered, begin search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        posts.removeAll()
        tableView.reloadData()
        
        let keywords = searchBar.text
        self.view.endEditing(true)
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "%20")
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)&type=track&market=US&limit=10"
        
        //search for songs
        if(accessToken != ""){
            self.callAlamo(url: self.searchURL)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get authorization token immediately
        getAlamoAuth()
    }
    
    //get an authorization token for search and input link
    func getAlamoAuth(){
        let parameters = ["client_id" : "a5656d6551e647cb98f7c561ecb245b5",
                          "client_secret" : "9513db168f93452c82f60b1e26280877",
                          "grant_type" : "client_credentials"]
        Alamofire.request("https://accounts.spotify.com/api/token", method: .post, parameters: parameters).responseJSON(completionHandler: {
            response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                self.accessToken = json["access_token"].stringValue
                //API call after token obtained
                print("gotAuth!")
            case .failure(let error):
                print(error)
            }
        })
    }
    
    //Spotify API call
    func callAlamo(url: String){
        print(searchURL)
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": String("Bearer " + String(accessToken))
        ]
        Alamofire.request(url, headers: headers).responseJSON(completionHandler:{
            response in
            self.parseData(JSONData: response.data!)
            print("sent request")
        })
    }
    
    //parse JSON data from API
    func parseData(JSONData: Data){
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                if let items = tracks["items"] as? [JSONStandard]{
                    for i in 0..<items.count{
                        let item = items[i]
                        let name = item["name"] as! String
                        var previewURL = ""
                        if let externalURLS = item["external_urls"] as? JSONStandard{
                            previewURL = (externalURLS["spotify"] as! String)
                            print(String(previewURL)!)
                        }
                        if let album = item["album"] as? JSONStandard{
                            if let images = album["images"] as? [JSONStandard]{
                                let imageData = images[0]
                                let imageURL = (imageData["url"] as! String)
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                let mainImage = UIImage(data: mainImageData! as Data)
                                
                                posts.append(post.init(mainImage: mainImage, name: name, previewURL: previewURL, imageURL: imageURL))
                                self.tableView.reloadData()
                            }
                        }
                        
                    }
                }
            }
        }catch{
            print(error)
        }
        print("done")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell")
        
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        mainImageView.image = posts[indexPath.row].mainImage
        
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = posts[indexPath.row].name
        
        return cell!
    }
    
    //upon song selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "backToMap", sender: self)
    }
    
    //go back to Map Editor (ViewController) and store location intoCoreData
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        let vc = segue.destination as! ViewController
        
        let newZone = NSEntityDescription.insertNewObject(forEntityName: "Zones", into: context)
        newZone.setValue(posts[indexPath!].previewURL, forKey: "songURI")
        newZone.setValue(posts[indexPath!].name, forKey: "song")
        newZone.setValue(mapCenterLatitude, forKey: "latitude")
        print(mapCenterLatitude)
        newZone.setValue(mapCenterLongitude, forKey: "longitude")
        newZone.setValue(posts[indexPath!].imageURL, forKey: "imageURL")
        newZone.setValue(100, forKey: "radius")
        
        do {
            try context.save()
            print("saved")
        }
        catch{
            print("couldn't save context, error bro!")
        }
        
    }
    
    //  CODE TO PLAY A SONG LINK IN SPOTIFY:
    //  UIApplication.shared.open(URL(string: posts[indexPath!].previewURL)!, options: [:], completionHandler: nil)
}
