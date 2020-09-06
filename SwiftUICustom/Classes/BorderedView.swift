//
//  BorderedView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation


public struct BorderedView<Content: View>: View {
	let content: Content
	let width: CGFloat
	let color: UIColor
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let view = self.content.toUIView(enclosingController: enclosingController)
		view.layer.borderWidth = self.width
		view.layer.borderColor = self.color.cgColor
		return view
	}
}

public extension View {
	func border(_ color: UIColor, lineWidth: CGFloat = 1) -> BorderedView<Self> {
		return BorderedView(content: self, width: lineWidth, color: color)
	}
}
