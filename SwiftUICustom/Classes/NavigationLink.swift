//
//  NavigationLink.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct NavigationLink<Content: View, Destination: View>: View {
	let destination: Destination
	let content: () -> Content
	
	public init(destination: Destination, content: @escaping () -> Content) {
		self.destination = destination
		self.content = content
	}
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let buttonControl = NavigationButtonLink(view: self.content().toUIView(enclosingController: enclosingController)) {
			enclosingController.navigationController?.pushViewController(SwiftUIInternalController(swiftUIView: self.destination), animated: true)
		}
		buttonControl.tintColor = .blue
		return buttonControl
	}
}

class NavigationButtonLink: ButtonView {
	override func insideList() -> (() -> ())? {
		guard !self.inList else { return self.onClick }
		self.inList = true
		self.view.tintColor = UIColor.black
		setupView(HStack {
			UIViewWrapper(view: self.view)
			Spacer()
			Text("->")
			}.padding().toUIView(enclosingController: UIViewController()))
		self.isUserInteractionEnabled = false
		return self.onClick
	}
	
	override var tintColor: UIColor! {
		didSet {
			self.view.tintColor = self.tintColor
		}
	}
}
