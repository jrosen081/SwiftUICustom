//
//  OnAppearView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct OnAppearView<Content: View>: View {
	let view: Content
	let onAppear: () -> ()
	
	public var body: Content {
		return self.view
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        environment.currentStateNode.buildingBlock = self.view
		let view = self.view._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = view
        DispatchQueue.main.async {
            onAppear()
        }
		return view
	}
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        self.view._redraw(view: view, controller: controller, environment: environment)
    }
}

public extension View {
	func onAppear(_ appear: @escaping () -> ()) -> OnAppearView<Self> {
		OnAppearView(view: self, onAppear: appear)
	}
}

