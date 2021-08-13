//
//  WindowGroup.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/21/21.
//

import Foundation

@available(iOS 13, *)
extension Never: Scene {}

extension Never: View {}

public extension Swift.Never {
    var body: Swift.Never {
        fatalError()
    }
}

@available(iOS 13, *)
public struct WindowGroup<ViewType: View>: Scene {
    let view: ViewType
    
    public init(@ViewBuilder content: () -> ViewType) {
        self.view = content()
    }
    
    public var body: Swift.Never {
        fatalError()
    }
    
    public static func _startScene(delegate: UIWindowSceneDelegate, self object: WindowGroup<ViewType>, domNode: DOMNode) -> UIViewController {
        let controller = SwiftUIController(swiftUIView: object.view)
        return controller
    }
    
    public static func _updateScene(delegate: UIWindowSceneDelegate, self: WindowGroup<ViewType>, domNode: DOMNode, controller: UIViewController) {
        guard let controller = controller as? SwiftUIController<ViewType> else { return }
        controller.updateData(with: nil)
    }
}
