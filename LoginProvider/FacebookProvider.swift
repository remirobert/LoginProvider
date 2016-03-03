//
//  FacebookProvider.swift
//  Bookme5IOS
//
//  Created by Remi Robert on 06/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit

class FacebookProvider: Provider {

    let providerType = LoginProviderType.Facebook
    var delegate: LoginProviderDelegate?

    private var parentController: UIViewController!
    private var permissions: [String]!
    
    init(parentController: UIViewController, permissions: [String] = ["public_profile", "email", "user_friends"]) {
        self.permissions = permissions
        self.parentController = parentController
    }
    
    func login() {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logOut()
        loginManager.loginBehavior = .Native
        
        loginManager.logInWithReadPermissions(self.permissions, fromViewController: self.parentController) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            
            if error != nil || result == nil {
                self.delegate?.loginProvider(self, didError: error)
            }
            else {
                if let token = result.token, let tokenString = token.tokenString {
                    print("get token facebook auth : \(tokenString)")
                    self.delegate?.loginProvider(self, didSucceed: APIAuth.Facebook(token: tokenString))
                }
                else {
                    self.delegate?.loginProvider(self, didError: NSError(domain: "Token not found", code: 404, userInfo: nil))
                }
            }
        }        
    }
}
