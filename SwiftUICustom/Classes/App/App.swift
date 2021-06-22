//
//  App.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/21/21.
//

import Foundation

var globalApp: Any? = nil
var sceneGetter: () -> Any = { 1 } // Use defaults here since these can't be passed directly

@available(iOS 13, *)
public protocol App {
    associatedtype SceneType: Scene
    var scene: SceneType { get }
    init()
    static func main()
}

@available(iOS 13, *)
extension App {
    public static func main() {
        let app = Self.init()
        globalApp = app
        sceneGetter = {
            app.scene
        }
        AppDelegate<Self>.main()
    }
}

@available(iOS 13, *)
class AppDelegate<AppType: App>: NSObject, UIApplicationDelegate {
    var app: AppType?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        guard let appValue = globalApp as? AppType else { return false }
        self.app = appValue
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let delegateClass = InternalSceneDelegate<AppType.SceneType>.self
        let config = UISceneConfiguration(name: nil, sessionRole: .windowApplication)
        config.delegateClass = delegateClass
        return config
    }
}
