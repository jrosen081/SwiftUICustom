//
//  EmptyView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/7/20.
//

import Foundation

public struct EmptyView: View {
	public init() {}
	
	public var body: EmptyView {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		return ShrinkingView()
	}
	
	public func redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		// Do nothing
	}
}

class ShrinkingView: UIView {
	override var intrinsicContentSize: CGSize {
		return .zero
	}
}
