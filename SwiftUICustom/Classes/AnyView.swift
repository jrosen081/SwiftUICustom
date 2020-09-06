//
//  AnyView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct AnyView: View {
	let viewCreator: (UIViewController) -> UIView
	
	public init<S: View>(_ view: S) {
		self.viewCreator = view.toUIView(enclosingController:)
	}
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		return self.viewCreator(enclosingController)
	}
}
