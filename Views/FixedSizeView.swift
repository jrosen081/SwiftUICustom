//
//  FixedSizeView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct FixedSizeView<Content: View>: View {
	let size: CGSize
	let content: Content
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = content.__toUIView(enclosingController: enclosingController, environment: environment)
		let horizontal = view.widthAnchor.constraint(equalToConstant: size.width)
		horizontal.priority = .required
		horizontal.isActive = true
		let vertical = view.heightAnchor.constraint(equalToConstant: size.height)
		vertical.priority = .required
		vertical.isActive = true
		return view
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.content._redraw(view: view, controller: controller, environment: environment)
	}
}

public extension View {
	func fixedSize(width: CGFloat, height: CGFloat) -> FixedSizeView<Self> {
		return FixedSizeView(size: CGSize(width: width, height: height), content: self)
	}
}
