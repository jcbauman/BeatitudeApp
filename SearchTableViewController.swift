//
//  SearchTableViewController.swift
//  Beatitude
//
//  Created by Rocko Bauman on 7/31/18.
//

import UIKit
import SwiftyJSON
import Alamofire

class SearchTableViewController: UITableViewController {

    var accessToken = ""
    var searchURL = "https://api.spotify.com/v1/search?q=Curtis%20Mayfield&type=track&limit=20"
    
    typealias JSONStandard = [String: AnyObject]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var authToken = getAlamoAuth()
        
        if authToken != "" {
            callAlamo(url: searchURL)
        }
        
    }
    
    func getAlamoAuth() -> String {
        let parameters = ["client_id" : "a5656d6551e647cb98f7c561ecb245b5",
                          "client_secret" : "3bf2f4cf94e440908654d356ab2fe3cf",
                          "grant_type" : "client_credentials"]
        
        var token = ""
        
        Alamofire.request("https://accounts.spotify.com/api/token", method: .post, parameters: parameters).responseJSON(completionHandler: {
            response in
           // print(response.result.value)
            switch response.result{
                case .success(let value):
                let json = JSON(value)
                token = json["access_token"].stringValue
                
            case .failure(let error):
                print(error)
            }
        })
        return token
    }
    

    func callAlamo(url: String){
        Alamofire.request(url).responseJSON(completionHandler:{
            response in
            self.parseData(JSONData: response.data!)
        })
    }

    func parseData(JSONData: Data){
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as? [String: AnyObject]
            print(readableJSON)

        }catch{
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
