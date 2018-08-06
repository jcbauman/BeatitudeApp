//
//  ManageZonesController.swift
//  Beatitude
//
//  Created by Rocko Bauman on 7/27/18.
//

import UIKit
import CoreData

class ManageZonesController: UITableViewController{

    var zoneArray:[Zones] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.fetchData()
        self.tableView.reloadData()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //print("Zone array count = ", zoneArray.count)  REMOVE
        return zoneArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongEditorTableViewCell
        let song = zoneArray[indexPath.row]
        
        let imageURL = URL(string: song.imageURL as! String)
        let mainImageData = NSData(contentsOf: imageURL!)
        let mainImage = UIImage(data: mainImageData! as Data)
        
        cell.albumLogo!.image = mainImage!
        cell.songTitle!.text = song.song!
    
        return cell
    }
    
    func fetchData(){
        do{
            zoneArray = try context.fetch(Zones.fetchRequest())
        }catch{
            print(error)
        }
    }
    
    //deletion handler
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let song = zoneArray[indexPath.row]
            context.delete(song)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do{
                zoneArray = try context.fetch(Zones.fetchRequest())
            }
            catch{
                print(error)
            }
            tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadMapAnnotations"), object: nil)
    }
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
