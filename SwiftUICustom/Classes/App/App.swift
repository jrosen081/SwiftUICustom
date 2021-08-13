//
//  App.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/21/21.
//

import Foundation

let globalViewController = UIViewController()

var globalApp: Any? = nil

@available(iOS 13, *)
var sceneGetter: AnyScene? = nil

@available(iOS 13, *)
private struct AppWrapper<A: App>: View {
    let app: A
    
    var body: Never {
        fatalError()
    }
    
    func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        return UIView()
    }
    
    func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let allScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let sceneState = _StateNode(view: app, node: environment.currentStateNode).scene
        allScenes.forEach { scene in
            guard let delegate = scene.delegate as? InternalSceneDelegate else { return }
            scene.windows.compactMap(\.rootViewController).forEach { controller in // Where do I get this node, maybe a global scope?
                type(of: sceneState)._updateScene(delegate: delegate, self: sceneState, domNode: delegate.domNode, controller: controller)
            }
        }
    }
}

@available(iOS 13, *)
public protocol App {
    associatedtype SceneType: Scene
    @SceneBuilder
    var scene: SceneType { get }
    init()
    static func main()
}

@available(iOS 13, *)
extension App {
    public static func main() {
        let app = Self.init()
        globalApp = app
        let globalDOMNode = DOMNode(environment: EnvironmentValues(), viewController: globalViewController, buildingBlock: AppWrapper(app: app))
        globalDOMNode.uiView = globalViewController.view
        sceneGetter = AnyScene(app, node: globalDOMNode)
        AppDelegate<Self>.main()
    }
}

protocol DelegateInserter: AnyObject {
    var delegate: UIApplicationDelegate? { get set }
}

@available(iOS 13, *)
class AppDelegate<AppType: App>: NSObject, UIApplicationDelegate, DelegateInserter {
    var app: AppType?
    var delegate: UIApplicationDelegate?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        guard let appValue = globalApp as? AppType else { return false }
        self.app = appValue
        _ = _StateNode(view: appValue, node: DOMNode(environment: EnvironmentValues(), viewController: nil, buildingBlock: EmptyView())).scene // Sets up the uiapplication delegate
        return delegate?.application?(application, willFinishLaunchingWithOptions: launchOptions) ?? true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let delegateClass = InternalSceneDelegate.self
        let config = UISceneConfiguration(name: nil, sessionRole: .windowApplication)
        config.delegateClass = delegateClass
        config.sceneClass = UIWindowScene.self
        return config
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if let delegate = self.delegate {
            return delegate.responds(to: aSelector)
        } else {
            return super.responds(to: aSelector)
        }
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let delegate = self.delegate, delegate.responds(to: aSelector) {
            return delegate
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }
}
