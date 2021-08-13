//
//  Scene.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/21/21.
//

import Foundation

@available(iOS 13, *)
public struct AnyScene: Scene {
    let sceneCreator: (UIWindowSceneDelegate, DOMNode) -> UIViewController
    let updater: (UIWindowSceneDelegate, DOMNode, UIViewController) -> Void
    let sequenceCreator: (DOMNode, UIWindowSceneDelegate) -> SceneSequence
    let responds: (NSUserActivity?) -> Bool
    
    init<A: App>(_ app: A, node appNode: DOMNode) {
        self.sequenceCreator = {
            _StateNode(view: app, node: appNode).scene._asSequence(domNode: $0, delegate: $1)
        }
        self.sceneCreator = {
            let scene = _StateNode(view: app, node: appNode).scene
            $1.buildingBlock = SceneWrapper(scene: scene, delegate: $0)
            return A.SceneType._startScene(delegate: $0, self: scene, domNode: $1)
        }
        self.updater = {
            A.SceneType._updateScene(delegate: $0, self: _StateNode(view: app, node: appNode).scene, domNode: $1, controller: $2)
        }
        self.responds = {
            _StateNode(view: app, node: appNode).scene.responds(to: $0)
        }
    }
    
    init<S: Scene>(scene: S) {
        self.sceneCreator = {
            S._startScene(delegate: $0, self: scene, domNode: $1)
        }
        
        self.updater = {
            S._updateScene(delegate: $0, self: scene, domNode: $1, controller: $2)
        }
        
        self.sequenceCreator = scene._asSequence
        self.responds = scene.responds(to:)
    }
    
    public var body: Never {
        fatalError()
    }
    
    public static func _startScene(delegate: UIWindowSceneDelegate, self: AnyScene, domNode: DOMNode) -> UIViewController {
        self.sceneCreator(delegate, domNode)
    }
    
    public static func _updateScene(delegate: UIWindowSceneDelegate, self: AnyScene, domNode: DOMNode, controller: UIViewController) {
        self.updater(delegate, domNode, controller)
    }
        
    public func _asSequence(domNode: DOMNode, delegate: UIWindowSceneDelegate) -> SceneSequence {
        return self.sequenceCreator(domNode, delegate)
    }
    
    public func responds(to type: NSUserActivity?) -> Bool {
        self.responds(type)
    }
}


@available(iOS 13.0, *)
public protocol Scene {
    associatedtype Body: Scene
    @SceneBuilder
    var body: Self.Body { get }
    static func _startScene(delegate: UIWindowSceneDelegate, self: Self, domNode: DOMNode) -> UIViewController
    static func _updateScene(delegate: UIWindowSceneDelegate, self: Self, domNode: DOMNode, controller: UIViewController)
    func responds(to type: NSUserActivity?) -> Bool
    func _asSequence(domNode: DOMNode, delegate: UIWindowSceneDelegate) -> SceneSequence
}

@available(iOS 13, *)
struct SceneWrapper<S: Scene>: View {
    let scene: S
    let delegate: UIWindowSceneDelegate
    var body: some View { self }
    func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        return UIView()
    }
    
    func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        S._updateScene(delegate: delegate, self: scene, domNode: environment.currentStateNode, controller: controller)
    }
    
}

@available(iOS 13, *)
extension Scene {
    func makeNode<S: Scene>(parentNode domNode: DOMNode, body: S, delegate: UIWindowSceneDelegate, index: Int = 0) -> DOMNode {
        let newNode = DOMNode(environment: domNode.environment, viewController: nil, buildingBlock: EmptyView())
        let environment = domNode.environment.withUpdates { $0.currentStateNode = newNode }
        newNode.environment = environment
        newNode.buildingBlock = SceneWrapper(scene: body, delegate: delegate)
        domNode.addChild(node: newNode, index: index)
        return newNode
    }
}

@available(iOS 13.0, *)
public extension Scene {
    
    func responds(to type: NSUserActivity?) -> Bool {
        if Self.Body.self == Never.self {
            return type == nil
        } else {
            return self.body.responds(to: type)
        }
    }
    
    func _asSequence(domNode: DOMNode, delegate: UIWindowSceneDelegate) -> SceneSequence {
        if Self.Body.self == Never.self {
            return SceneSequence(count: 1, sceneGetter: {_,node,_   in (AnyScene(scene: self), node) })
        } else {
            let childNode = domNode.childNodes.first ?? makeNode(parentNode: domNode, body: body, delegate: delegate)
            let childSequence = _StateNode(view: self, node: domNode).body._asSequence(domNode: childNode, delegate: delegate)
            return SceneSequence(count: childSequence.count) { index, node, delegate in
                let body = _StateNode(view: self, node: node).body
                let newNode = node.childNodes.first ?? makeNode(parentNode: node, body: body, delegate: delegate)
                return childSequence.sceneGetter(index, newNode, delegate)
            }
        }
    }
    
    static func _startScene(delegate: UIWindowSceneDelegate, self: Self, domNode: DOMNode) -> UIViewController {
        guard let delegate = delegate as? InternalSceneDelegate else { fatalError() }
        let sequence = self._asSequence(domNode: domNode, delegate: delegate)
        for i in 0 ..< sequence.count {
            let (scene, internalDomNode) = sequence.sceneGetter(i, domNode, delegate)
            if (scene.responds(to: delegate.activityType)) {
                let controller = AnyScene._startScene(delegate: delegate, self: scene, domNode: internalDomNode)
                domNode.viewController = controller
                internalDomNode.viewController = controller
                domNode.uiView = controller.view
                internalDomNode.uiView = controller.view
                return controller
            }
        }
        let (scene, internalDomNode) = sequence.sceneGetter(0, domNode, delegate)
        let controller = AnyScene._startScene(delegate: delegate, self: scene, domNode: internalDomNode)
        domNode.viewController = controller
        internalDomNode.viewController = controller
        domNode.uiView = controller.view
        internalDomNode.uiView = controller.view
        return controller
    }
    
    static func _updateScene(delegate: UIWindowSceneDelegate, self: Self, domNode: DOMNode, controller: UIViewController) {
        guard let delegate = delegate as? InternalSceneDelegate else { fatalError() }
        let sequence = self._asSequence(domNode: domNode, delegate: delegate)
        
        for i in 0 ..< sequence.count {
            let (scene, internalDomNode) = sequence.sceneGetter(i, domNode, delegate)
            if (scene.responds(to: delegate.activityType)) {
                AnyScene._updateScene(delegate: delegate, self: scene, domNode: internalDomNode, controller: controller)
                return
            }
        }
        
        let (scene, internalDomNode) = sequence.sceneGetter(0, domNode, delegate)
        AnyScene._updateScene(delegate: delegate, self: scene, domNode: internalDomNode, controller: controller)
    }
}

@available(iOS 13.0, *)
class InternalSceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?
    let domNode = DOMNode(environment: EnvironmentValues(), viewController: nil, buildingBlock: EmptyView())
    var activityType: NSUserActivity?
    var scene: AnyScene? {
        sceneGetter
    }
    
    override init() {
        super.init()
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene, let swiftScene = self.scene else { return }
        self.activityType = connectionOptions.userActivities.first
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = AnyScene._startScene(delegate: self, self: swiftScene, domNode: domNode)
        domNode.viewController = window.rootViewController
        window.makeKeyAndVisible()
    }
    
}
