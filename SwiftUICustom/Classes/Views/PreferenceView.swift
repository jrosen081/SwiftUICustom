//
//  PreferenceView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/28/21.
//

import Foundation

public struct PreferenceUpdatingView<Content: View, K: PreferenceKey>: View {
    let content: Content
    let value: K.Value
    
    public var body: Self {
        return self
    }
    
    public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let environmentValue = environment[EnvironmentPreferenceKey<K>.self]
        environmentValue.setValue(value: value)
        var newEnvironment = environment
        newEnvironment[EnvironmentPreferenceKey<K>.self] = environmentValue
        newEnvironment.currentStateNode.buildingBlock = self.content
        let view = self.content._toUIView(enclosingController: enclosingController, environment: newEnvironment)
        newEnvironment.currentStateNode.uiView = view
        return view
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        self.content._redraw(view: view, controller: controller, environment: environment)
    }
}

extension View {
    func preference<K>(key: K.Type = K.self, value: K.Value) -> PreferenceUpdatingView<Self, K> where K : PreferenceKey {
        return PreferenceUpdatingView(content: self, value: value)
    }
}
