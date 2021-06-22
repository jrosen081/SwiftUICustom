//
//  WindowGroup.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/21/21.
//

import Foundation

@available(iOS 13, *)
extension Swift.Never: Scene {
    public var body: Swift.Never {
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
    
    public static func _startScene(delegate: UIWindowSceneDelegate, self object: WindowGroup<ViewType>) -> UIViewController {
        return SwiftUIController(swiftUIView: object.view)
    }
}
