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
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let view = self.view.toUIView(enclosingController: enclosingController)
		if let swiftView = view as? SwiftUIView {
			swiftView.onAppear = self.onAppear
		}
		return view
	}
}

public extension View {
	func onAppear(_ appear: @escaping () -> ()) -> OnAppearView<Self> {
		OnAppearView(view: self, onAppear: appear)
	}
}

