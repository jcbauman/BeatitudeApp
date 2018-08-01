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

var player = AVAudioPlayer()

struct post{
    let mainImage : UIImage!
    let name: String!
    let previewURL: String!
}

class SearchTableViewController: UITableViewController, UISearchBarDelegate {

    var accessToken = ""
    var searchURL = String()
    var posts = [post]()
    typealias JSONStandard = [String: AnyObject]
    
    @IBOutlet var searchBar: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keywords = searchBar.text
        print("hiding keyboard000909090909")
        self.view.endEditing(true)
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "%20")
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)&type=track&market=US&limit=20"
        getAlamoAuth()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //get an authorization token for search and input link
    func getAlamoAuth(){
        let parameters = ["client_id" : "a5656d6d551e647cb98f7c561ecb245b5",
                          "client_secret" : "3bf2f4cf94e440908654d356ab2fe3cf",
                          "grant_type" : "client_credentials"]
        Alamofire.request("https://accounts.spotify.com/api/token", method: .post, parameters: parameters).responseJSON(completionHandler: {
            response in
            switch response.result{
                case .success(let value):
                let json = JSON(value)
                self.accessToken = json["access_token"].stringValue
                
                //API call after token obtained
                self.callAlamo(url: self.searchURL)
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
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                if let items = tracks["items"] as? [JSONStandard]{
                    for i in 0..<items.count{
                        let item = items[i]
                        print(item)
                        let name = item["name"] as! String
                        let previewURL = item["preview_url"] as! String
                        if let album = item["album"] as? JSONStandard{
                            if let images = album["images"] as? [JSONStandard]{
                                let imageData = images[0]
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                let mainImage = UIImage(data: mainImageData as! Data)
                                
                                posts.append(post.init(mainImage: mainImage, name: name, previewURL: previewURL))
                                self.tableView.reloadData()
                            }
                        }
                        
                    }
                }
            }
        }catch{
            print(error)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       let indexPath = self.tableView.indexPathForSelectedRow?.row
        let vc = segue.destination as! AudioViewController
        vc.mainSongTitle = posts[indexPath!].name
        vc.mainPreviewURL = posts[indexPath!].previewURL
    }
}
