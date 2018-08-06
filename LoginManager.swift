//
//  LoginManager.swift
//  Beatitude

import Foundation
import SafariServices

protocol LoginManagerDelegate: class {
    func loginManagerDidLoginWithSuccess()
}

class LoginManager {
    
    static var shared = LoginManager()
    private init() {
        auth.sessionUserDefaultsKey = "CurrentSession"
        auth.redirectURL = URL(string: "beatitude://")
        auth.clientID = "a5656d6551e647cb98f7c561ecb245b5"
        auth.requestedScopes = [SPTAuthStreamingScope]
    }
    
    weak var delegate: LoginManagerDelegate?
    var auth = SPTAuth.defaultInstance()!
    private var session: SPTSession? {
        if let sessionObject = UserDefaults.standard.object(forKey: auth.sessionUserDefaultsKey) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: sessionObject) as? SPTSession
        }
        return nil
    }
    var isLogged: Bool {
        if let session = session {
            return session.isValid()
        }
        return false
    }
    
    func preparePlayer() {
        guard let session = session else { return }
        MediaPlayer.shared.configurePlayer(authSession: session, id: auth.clientID)
    }
    
    func login() {
        let safariVC = SFSafariViewController(url: auth.spotifyWebAuthenticationURL())
        UIApplication.shared.keyWindow?.rootViewController?.present(safariVC, animated: true, completion: nil)
    }
    
    func handled(url: URL) -> Bool {
        guard auth.canHandle(auth.redirectURL) else {return false}
        auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
            if error != nil {
                print("error!")
            }
            print("RECEIVED AUTHORIZATION")
            self.delegate?.loginManagerDidLoginWithSuccess()
            self.preparePlayer()
        })
        return true
    }
}
