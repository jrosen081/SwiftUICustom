//
//  NavigationView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct NavigationView<Content: View>: View {
	let viewBuilder: () -> Content
	
	public init(_ viewBuilder: @escaping () -> Content) {
		self.viewBuilder = viewBuilder
	}
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		enclosingController.navigationController?.isNavigationBarHidden = false
		return self.viewBuilder().toUIView(enclosingController: enclosingController)
	}
}
