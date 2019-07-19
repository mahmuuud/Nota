//
//  AuthenticationViewController.swift
//  Nota
//
//  Created by mahmoud mohamed on 7/12/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class AuthenticationViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        //GIDSignIn.sharedInstance().signIn()
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil{
            print("Error signing in")
            return
        }
        guard let auth = user.authentication else{return}
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            print("signed in")
            UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "userId")
            self.performSegue(withIdentifier: "authPerformed", sender: nil)
        }
    }
}
