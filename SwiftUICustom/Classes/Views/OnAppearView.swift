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
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = self.view.__toUIView(enclosingController: enclosingController, environment: environment)
		onAppear()
		return view
	}
}

public extension View {
	func onAppear(_ appear: @escaping () -> ()) -> OnAppearView<Self> {
		OnAppearView(view: self, onAppear: appear)
	}
}

