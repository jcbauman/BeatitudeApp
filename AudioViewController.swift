//
//  AudioViewController.swift
//  Beatitude
//
//  Created by Rocko Bauman on 8/1/18.
//  Copyright © 2018 Rocko Bauman. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class AudioViewController: UIViewController {

    var mainSongTitle = String()
    var mainPreviewURL = String()
    
    @IBOutlet weak var pausePlay: UIButton!
    @IBOutlet weak var songTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songTitle.text = mainSongTitle
        downloadFileFromURL(url: URL(string: mainPreviewURL)!)
        pausePlay.setTitle("Pause", for: .normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadFileFromURL(url: URL){
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in
            self.play(url: customURL!)
        })
        downloadTask.resume()
    }
    
    func play(url: URL){
        do{
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
        } catch {
            print(error)
        }
    }
    @IBAction func pausePlayPressed(_ sender: Any) {
        if player.isPlaying{
            player.pause()
            pausePlay.setTitle("Play", for: .normal)
        }
        else {
            player.play()
            pausePlay.setTitle("Pause", for: .normal)
        }
    }
    
}
