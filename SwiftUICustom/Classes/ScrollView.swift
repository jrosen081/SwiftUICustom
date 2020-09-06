//
//  ScrollView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct ScrollView<Content: View>: View {
	let viewBuilder: () -> Content
	
	public init(@ViewBuilder _ viewBuilder: @escaping () -> Content) {
		self.viewBuilder = viewBuilder
	}
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let scrollView = SwiftUIScrollView(frame: .zero)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		let scrollableView = self.viewBuilder().toUIView(enclosingController: enclosingController).asTopLevelView()
		scrollView.addSubview(scrollableView)
		NSLayoutConstraint.activate([
			scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: scrollableView.leadingAnchor),
			scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: scrollableView.trailingAnchor),
			scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: scrollableView.topAnchor),
			scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: scrollableView.bottomAnchor)
		])
		return scrollView
	}
}

class SwiftUIScrollView: UIScrollView {
	override var intrinsicContentSize: CGSize {
		UILayoutFittingExpandedSize
	}
	
	override var tintColor: UIColor! {
		didSet {
			self.subviews.forEach { $0.tintColor = self.tintColor }
		}
	}
}
