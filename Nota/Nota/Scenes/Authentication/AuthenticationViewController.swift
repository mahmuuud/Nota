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

class AuthenticationViewController: UIViewController,GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }

}
