//
//  LoginProvider.swift
//  Bookme5IOS
//
//  Created by Remi Robert on 06/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import Alamofire
import PINRemoteImage
import RxSwift
import Moya

typealias successCompletionRequestBlock = ((auth: APIAuth) -> Void)
typealias errorCompletionBlock = ((error: NSError?) -> Void)

enum LoginProviderType: String {
    case Facebook = "Facebook"
    case Google = "Google"
    case Email = "Email"
}

protocol Provider {
    var providerType: LoginProviderType {get}
    var delegate: LoginProviderDelegate? {get set}
    func login()
}

protocol LoginProviderDelegate {
    func loginProvider(loginProvider: Provider, didSucceed auth: APIAuth)
    func loginProvider(loginProvider: Provider, didError error: NSError?)
}

class LoginProvider: LoginProviderDelegate {
    
    private var successRequestBlock: successCompletionRequestBlock?
    private var errorRequestBlock: errorCompletionBlock?
    private let disposeBag = DisposeBag()
    private var observble: Observable<Request>?
    
    var currentProvider: Provider!

    private func login(var provider: Provider, completionRequest: successCompletionRequestBlock, completionError: errorCompletionBlock) {
        self.successRequestBlock = completionRequest
        self.errorRequestBlock = completionError
        self.currentProvider = provider
        provider.delegate = self
        provider.login()
    }
    
    func rx_login(provider: Provider) -> Observable<String> {
        return Observable.create({ observer in
            
            self.login(provider, completionRequest: { (auth) -> Void in
                MoyaProviderAuth.requestAuth(auth).subscribe(onNext: { response in
                    do {
                        let json = try response.mapJSON()
                        if let token = json["token"] as? String {
                            observer.onNext(token)
                            observer.onCompleted()
                        }
                        else {
                            observer.onError(NSError(domain: "Token not found", code: 404, userInfo: nil))
                        }
                    }
                    catch {
                        observer.onError(NSError(domain: "Token not found", code: 404, userInfo: nil))
                    }
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil,
                    onDisposed: nil).addDisposableTo(self.disposeBag)
                }, completionError: { (error) -> Void in
                    observer.onError(error!)
            })
            
            return NopDisposable.instance
        })
    }
    
    internal func loginProvider(loginProvider: Provider, didSucceed auth: APIAuth) {
        self.successRequestBlock?(auth: auth)
    }
    
    internal func loginProvider(loginProvider: Provider, didError error: NSError?) {
        self.errorRequestBlock?(error: error)
    }
}