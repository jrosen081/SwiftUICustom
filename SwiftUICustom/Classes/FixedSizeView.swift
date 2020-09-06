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
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let view = content.toUIView(enclosingController: enclosingController)
		let horizontal = view.widthAnchor.constraint(equalToConstant: size.width)
		horizontal.priority = .required
		horizontal.isActive = true
		let vertical = view.heightAnchor.constraint(equalToConstant: size.height)
		vertical.priority = .required
		vertical.isActive = true
		return view
	}
}

public extension View {
	func fixedSize(width: CGFloat, height: CGFloat) -> FixedSizeView<Self> {
		return FixedSizeView(size: CGSize(width: width, height: height), content: self)
	}
}
