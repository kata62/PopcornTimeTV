import UIKit
import PopcornKit
import Reachability
import ObjectMapper

#if os(iOS)
import AlamofireNetworkActivityIndicator
import GoogleCast
#endif

#if os(tvOS)
import TVServices
#endif

public let vlcSettingTextEncoding = "subsdec-encoding"

struct ColorPalette {
    let primary: UIColor
    let secondary: UIColor
    let tertiary: UIColor
    
    private init(primary: UIColor, secondary: UIColor, tertiary: UIColor) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }
    
    static let light = ColorPalette(primary: .white,
                                    secondary: UIColor.white.withAlphaComponent(0.667),
                                    tertiary: UIColor.white.withAlphaComponent(0.333))
    
    static let dark = ColorPalette(primary: .black,
                                   secondary: UIColor.black.withAlphaComponent(0.667),
                                   tertiary: UIColor.black.withAlphaComponent(0.333))
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    static var shared: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to cast UIApplication delegate to AppDelegate")
        }
        return delegate
    }

    var window: UIWindow?

    var reachability: Reachability?

    var tabBarController: UITabBarController {
        guard let tabBar = window?.rootViewController as? UITabBarController else {
            fatalError("RootViewController is not a UITabBarController")
        }
        return tabBar
    }
    
    var activeRootViewController: MainViewController? {
        guard
            let navigationController = tabBarController.selectedViewController as? UINavigationController,
            let main = navigationController.viewControllers.compactMap({ $0 as? MainViewController }).first
        else {
            return nil
        }
        return main
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if os(tvOS)
        if let url = launchOptions?[.url] as? URL {
            return self.application(application, open: url)
        }
        NotificationCenter.default.post(name: NSNotification.Name.TVTopShelfItemsDidChange, object: nil)
        let font = UIFont.systemFont(ofSize: 38, weight: .heavy)
        UITabBarItem.appearance().setTitleTextAttributes([.font: font], for: .normal)
        #elseif os(iOS)
        NetworkActivityIndicatorManager.shared.isEnabled = true

        GCKCastContext.setSharedInstanceWith(
            GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: kGCKDefaultMediaReceiverApplicationID))
        )
        tabBarController.delegate = self
        #endif

        if !UserDefaults.standard.bool(forKey: "tosAccepted") {
            let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "TermsOfServiceNavigationController")
            window?.makeKeyAndVisible()
            UserDefaults.standard.set(0.75, forKey: "themeSongVolume")
            OperationQueue.main.addOperation {
                self.activeRootViewController?.present(vc, animated: false) {
                    self.activeRootViewController?.environmentsToFocus = [self.tabBarController.tabBar]
                }
            }
        }

        do {
            reachability = try Reachability()
            try reachability?.startNotifier()
        } catch {
            print("Failed to start Reachability notifier: \(error)")
        }

        window?.tintColor = .app
        TraktManager.shared.syncUserData()
        awakeObjects()

        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController == viewController,
           let scrollView = viewController.view.recursiveSubviews.compactMap({ $0 as? UIScrollView }).first {
            let offset = CGPoint(x: 0, y: -scrollView.contentInset.top)
            scrollView.setContentOffset(offset, animated: true)
        }
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        #if os(tvOS)
        if url.scheme == "PopcornTime" {
            guard
                let actions = url.absoluteString.removingPercentEncoding?
                    .components(separatedBy: "PopcornTime:?action=").last?
                    .components(separatedBy: "»"),
                let type = actions.first,
                let json = actions.last
            else {
                return false
            }

            guard let media: Media = (type == "showMovie"
                                      ? Mapper<Movie>().map(JSONString: json)
                                      : Mapper<Show>().map(JSONString: json)) else {
                return false
            }

            if let vc = activeRootViewController {
                let storyboard = UIStoryboard.main
                let loadingViewController = storyboard.instantiateViewController(withIdentifier: "LoadingViewController")
                
                let segue = AutoPlayStoryboardSegue(identifier: type, source: vc, destination: loadingViewController)
                vc.prepare(for: segue, sender: media)

                tabBarController.tabBar.isHidden = true
                vc.navigationController?.pushViewController(loadingViewController, animated: true)
            }
        }
        #elseif os(iOS)
        if let sourceApplication = options[.sourceApplication] as? String,
           (sourceApplication == "com.apple.SafariViewService" || sourceApplication == "com.apple.mobilesafari"),
           url.scheme == "popcorntime" {
            TraktManager.shared.authenticate(url)
        } else if url.scheme == "magnet" || url.isFileURL {
            let torrentUrl: String
            let id: String

            if url.scheme == "magnet" {
                torrentUrl = url.absoluteString
                id = torrentUrl
            } else {
                torrentUrl = url.path
                id = url.lastPathComponent
            }

            let torrent = Torrent(url: torrentUrl)
            let media: Media = Movie(id: id, torrents: [torrent]) // Type here is arbitrary.

            play(media, torrent: torrent)
        }
        #endif

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Handle app becoming inactive (e.g., phone call, SMS).
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Handle backgrounding (save state, stop services, etc.).
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Prepare to return to active state from background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Resume tasks or refresh UI.
        UpdateManager.shared.checkVersion(.daily)
    }

    func awakeObjects() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        defer { types.deallocate() }

        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyObject.Type>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))

        for index in 0 ..< typeCount {
            (types[index] as? Object.Type)?.awake()
        }
    }
}
