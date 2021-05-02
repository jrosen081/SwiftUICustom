//
//  ScrollView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct ScrollView<Content: View>: View {
	let viewBuilder: Content
	
	public init(@ViewBuilder _ viewBuilder: () -> Content) {
		self.viewBuilder = viewBuilder()
	}
	
	public var body: Content {
        return self.viewBuilder
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let scrollView = SwiftUIScrollView(frame: .zero)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		let scrollableView = self.viewBuilder.__toUIView(enclosingController: enclosingController, environment: environment).asTopLevelView()
		scrollView.addSubview(scrollableView)
		NSLayoutConstraint.activate([
			scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: scrollableView.leadingAnchor),
			scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: scrollableView.trailingAnchor),
			scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: scrollableView.topAnchor),
			scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: scrollableView.bottomAnchor)
		])
		return scrollView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.viewBuilder._redraw(view: view.subviews[0], controller: controller, environment: environment)
	}
}

class SwiftUIScrollView: UIScrollView {
	override var intrinsicContentSize: CGSize {
		UIView.layoutFittingExpandedSize
	}
	
	override func willExpand(in context: ExpandingContext) -> Bool {
		return true
	}
}
