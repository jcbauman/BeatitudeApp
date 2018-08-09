//
//  MainInfoPopup.swift
//  Beatitude
//
//  Created by Rocko Bauman on 8/9/18.
//  Copyright © 2018 Rocko Bauman. All rights reserved.
//

import UIKit

class MainInfoPopup: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tappyRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissInfoBox))
        view.addGestureRecognizer(tappyRecognizer)
        // Do any additional setup after loading the view.
        
        view.center = self.view.center
        view.alpha = 0
        view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        UIImageView.animate(withDuration: 0.5){
            self.view.alpha = 1
            self.view.transform = CGAffineTransform.identity
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //hide help info box
    func dismissInfoBox(recognizer: UITapGestureRecognizer) {
        UIImageView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
            self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        }){(success: Bool) in
            self.view.removeFromSuperview()
        }
    }
  
}
