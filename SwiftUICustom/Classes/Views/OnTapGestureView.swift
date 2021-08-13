//
//  OnTapGestureView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/15/20.
//

import Foundation

public struct OnTapGestureView<Content: View>: View {
	let content: Content
	let onClick: () -> ()
    let reload: Bool
	
    public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        environment.currentStateNode.buildingBlock = self.content
        let view = content._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = view
		let buttonView = ButtonView(view: view, onClick: onClick)
		buttonView.alphaToChangeTo = 1
		return buttonView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let button = view as? ButtonView else { return }
        button.onClick = onClick
		self.content._redraw(view: view.subviews[0], controller: controller, environment: environment)
	}
}

extension View {
    func onTapGestureReloading(_ onclick: @escaping () -> ()) -> OnTapGestureView<Self> {
        return OnTapGestureView(content: self, onClick: onclick, reload: true)
    }
}

public extension View {
	func onTapGesture(_ onClick: @escaping () -> ()) -> OnTapGestureView<Self> {
        return OnTapGestureView(content: self, onClick: onClick, reload: false)
	}
}
