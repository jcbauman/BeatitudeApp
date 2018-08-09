//
//  SearchTableViewController.swift
//  Beatitude
//
//  Created by Rocko Bauman on 7/31/18.
//
import UIKit
import SwiftyJSON
import Alamofire
import CoreData
import Foundation


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
    var mapSpan = Double()
    var numberOfSongsLoaded = Int()
    
    var accessToken = ""
    var searchURL = String()
    var posts = [post]()
    typealias JSONStandard = [String: AnyObject]
    
    let loadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingBar: UIProgressView!
    
    //CoreData initializtion
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //when search bar triggered, begin search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        posts.removeAll()
        tableView.reloadData()
        loadingLabel.text = "Loading songs, one moment..."
        
        loadingLabel.isHidden = false
        let keywords = searchBar.text
        self.view.endEditing(true)
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "%20")
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)&type=track&market=US&limit=12"
        
        //search for songs
        if(accessToken != ""){
            self.callAlamo(url: self.searchURL)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // loadingBar.isHidden = true
        loadingLabel.center = self.view.center
        loadingLabel.textAlignment = .center
        loadingLabel.font = UIFont(name: "Futura", size: 14)
        self.view.addSubview(loadingLabel)
        loadingLabel.isHidden = true
        navigationItem.leftBarButtonItem?.tintColor = UIColor.yellow
        
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
            case .failure(let error):
                print(error)
            }
        })
    }
    
    //Spotify API call
    func callAlamo(url: String){
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": String("Bearer " + String(accessToken))
        ]
        Alamofire.request(url, headers: headers).responseJSON(completionHandler:{
            response in
            self.parseData(JSONData: response.data!)
        })
    }
    
    //parse JSON data from API
    func parseData(JSONData: Data){
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            numberOfSongsLoaded = 0
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                if let items = tracks["items"] as? [JSONStandard]{
                    for i in 0..<items.count{
                        let item = items[i]
                        let name = item["name"] as! String
                        let previewURL = item["uri"] as! String
                        if let album = item["album"] as? JSONStandard{
                            if let images = album["images"] as? [JSONStandard]{
                                let imageData = images[0]
                                let imageURL = (imageData["url"] as! String)
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                let mainImage = UIImage(data: mainImageData! as Data)
                                
                                numberOfSongsLoaded = numberOfSongsLoaded + 1
                                posts.append(post.init(mainImage: mainImage, name: name, previewURL: previewURL, imageURL: imageURL))
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }catch{
        }
        if posts.count == 0{
            loadingLabel.text = "No results, try again"
        }
        else{
            loadingLabel.isHidden = true
            loadingBar.isHidden = true
        }
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
    
    //upon song selection, go back to Map Editor (ViewController) and store location intoCoreData
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        
        let newZone = NSEntityDescription.insertNewObject(forEntityName: "Zones", into: context)
        newZone.setValue(posts[indexPath!].previewURL, forKey: "songURI")
        newZone.setValue(posts[indexPath!].name, forKey: "song")
        newZone.setValue(mapCenterLatitude, forKey: "latitude")
        newZone.setValue(mapCenterLongitude, forKey: "longitude")
        newZone.setValue(posts[indexPath!].imageURL, forKey: "imageURL")
        newZone.setValue((mapSpan * 29000.0), forKey: "radius")
        do {
            try context.save()
        }
        catch{
        }
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "justAddedNewZone"), object: nil)

    }
}
