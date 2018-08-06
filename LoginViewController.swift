//
//  LoginViewController.swift
//  Beatitude
//
//  Created by Rocko Bauman on 8/4/18.
//  Copyright © 2018 Rocko Bauman. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController{
    @IBOutlet weak var connectWithSpot: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectWithSpot.layer.cornerRadius = 28;
        connectWithSpot.clipsToBounds = true;
        
        LoginManager.shared.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectPressed(_ sender: Any) {
        LoginManager.shared.login()
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}


extension LoginViewController: LoginManagerDelegate {
    func loginManagerDidLoginWithSuccess() {
//    UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController.swift")
       DispatchQueue.main.async() {
        self.dismiss(animated: true, completion: nil)
        print("DISMISSED")
        self.performSegue(withIdentifier: "loggedIn", sender: self)
        print("SEGUED")
        }
    }
}
