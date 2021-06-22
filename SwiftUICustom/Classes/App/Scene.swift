//
//  Scene.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/21/21.
//

import Foundation

@available(iOS 13.0, *)
public protocol Scene {
    associatedtype Body: Scene
    var body: Self.Body { get }
    static func _startScene(delegate: UIWindowSceneDelegate, self: Self) -> UIViewController
}

@available(iOS 13.0, *)
extension Scene {
    public static func _startScene(delegate: UIWindowSceneDelegate, self: Self) -> UIViewController {
        let body = self.body
        return type(of: body)._startScene(delegate: delegate, self: body)
    }
}

@available(iOS 13.0, *)
class InternalSceneDelegate<SceneType: Scene>: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?
    var scene: SceneType? {
        sceneGetter() as? SceneType
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene, let swiftScene = self.scene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = type(of: swiftScene)._startScene(delegate: self, self: swiftScene)
        window.makeKeyAndVisible()
    }
    
}
