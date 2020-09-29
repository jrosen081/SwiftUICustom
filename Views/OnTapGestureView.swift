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
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let buttonView = ButtonView(view: content.__toUIView(enclosingController: enclosingController, environment: environment), onClick: onClick)
		buttonView.alphaToChangeTo = 1
		return buttonView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let button = view as? ButtonView else { return }
		button.onClick = self.onClick
		self.content._redraw(view: view.subviews[0], controller: controller, environment: environment)
	}
}

public extension View {
	func onTapGesture(_ onClick: @escaping () -> ()) -> OnTapGestureView<Self> {
		return OnTapGestureView(content: self, onClick: onClick)
	}
}
