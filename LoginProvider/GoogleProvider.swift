//
//  GoogleProvider.swift
//  BookMe5iOS
//
//  Created by Remi Robert on 06/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import Alamofire

class GoogleProvider: NSObject, Provider, GIDSignInDelegate, GIDSignInUIDelegate {

    let providerType = LoginProviderType.Google
    var delegate: LoginProviderDelegate?
    var parentController: UIViewController!
    
    @objc func signIn(signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
            self.parentController.presentViewController(viewController, animated: true, completion: nil)
    }
    
    @objc func signIn(signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
            self.parentController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error == nil) {
            let idToken = user.authentication.idToken
            self.delegate?.loginProvider(self, didSucceed: APIAuth.Google(token: idToken))
        }
        else {
            self.delegate?.loginProvider(self, didError: error)
        }
    }
    
    func login() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    init(parentController: UIViewController) {
        self.parentController = parentController
    }
}
