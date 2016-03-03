# LoginProvider
**LoginProvider** is a sample tool to add login with tiers service (as Facebook, Google, or Twitter), using **RxSwift**.


              |  CameraEngine
--------------------------|------------------------------------------------------------
:star2: | RxSwift implementation
:star2: | Modulable, and easy to extend
F | Facebook integration
G | Google+ integration

#How to create a LoginProvider

Following to the **protocol**, you can create your own Provider.

```Swift
protocol Provider {
  var providerType: LoginProviderType {get}
  var delegate: LoginProviderDelegate? {get set}
  func login()
}
```

Example of a Provider login with Email :

```swift
class EmailProvider: Provider {

    private var email: String
    private var password: String

    let providerType = LoginProviderType.Email
    var delegate: LoginProviderDelegate?
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    func isValid() -> Bool {
        //check the email here regex or everything you want.
        //If you don't know what you want, please skip this method 😳.
        //Avoid the boring stuff please.
        return true
    }
    
    func login() {
        if self.isValid() {
            //You can make a call here in your API to fetch auth return
            self.delegate?.loginProvider(self, didSucceed: APIAuth.Email(email: self.email, password: self.password))
        }
        else {
            self.delegate?.loginProvider(self, didError: nil)
        }
    }    
}
```

#RxSwift

To handle the login more easier, and more generic, RxSwft is used to handle the return of the Provider.

```Swift
class ViewController: UIViewController {

    @IBOutlet weak var buttonGoogleConnect: UIButton!
    @IBOutlet weak var buttonFacebookConnect: UIButton!

    private let disposeBag = DisposeBag()

    private lazy var observerGoogle: Observable<Provider>! = {
        self.buttonGoogleConnect.rx_tap.map {
            return GoogleProvider(parentController: self)
        }
    }()

    private lazy var observerFacebook: Observable<Provider>! = {
        self.buttonFacebookConnect.rx_tap.map {
            return FacebookProvider(parentController: self)
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.of(self.observerFacebook, self.observerGoogle)
            .merge()
            .flatMap { (provider: Provider) -> Observable<Bool> in
                return self.loginViewModel.login(self.loginProvider, provider: provider)
            }.subscribe { (event) -> Void in
                switch event {
                case .Completed: print("success")
                case .Error(let error): print("get errro : \(error)")
                default: break
                }
            }.addDisposableTo(self.disposeBag)
    }
}
```
