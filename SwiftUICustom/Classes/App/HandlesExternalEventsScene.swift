//
//  HandlesExternalEventsScene.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/7/21.
//

import Foundation

@available(iOS 13, *)
struct HandleExternalEventsScene<S: Scene>: Scene {
    let s: S
    let events: Set<String>
    
    public var body: some Scene { s }
    
    public func responds(to type: NSUserActivity?) -> Bool {
        guard let type = type, let contentType = type.targetContentIdentifier else { return false }
        return events.contains(where: contentType.contains)
    }
    
    func _asSequence(domNode: DOMNode, delegate: UIWindowSceneDelegate) -> SceneSequence {
        return SceneSequence(count: 1, sceneGetter: { _, node, _ in
            (AnyScene(scene: self), node)
        })
    }
}

@available(iOS 13, *)
public extension WindowGroup {
    func handlesExternalEvents(matching conditions: Set<String>) -> some Scene {
        HandleExternalEventsScene(s: self, events: conditions)
    }
}
