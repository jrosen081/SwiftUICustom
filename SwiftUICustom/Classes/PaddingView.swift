//
//  PaddingView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public enum Corner {
	case leading
	case trailing
	case top
	case bottom
}

public struct PaddingView<Content: View>: View {
	let paddingCorners: [Corner]
	let paddingSpace: CGFloat
	let underlyingView: Content
	
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let paddingView = SwiftUIView()
		let underlyingUIView = self.underlyingView.toUIView(enclosingController: enclosingController)
		paddingView.addSubview(underlyingUIView)
		paddingView.translatesAutoresizingMaskIntoConstraints = false
		paddingView.bottomAnchor.constraint(equalTo: underlyingUIView.bottomAnchor, constant: paddingCorners.contains(.bottom) ? self.paddingSpace : 0).isActive = true
		paddingView.topAnchor.constraint(equalTo: underlyingUIView.topAnchor, constant: paddingCorners.contains(.top) ? -self.paddingSpace : 0).isActive = true
		paddingView.leadingAnchor.constraint(equalTo: underlyingUIView.leadingAnchor, constant: paddingCorners.contains(.leading) ? -self.paddingSpace : 0).isActive = true
		paddingView.trailingAnchor.constraint(equalTo: underlyingUIView.trailingAnchor, constant: paddingCorners.contains(.trailing) ? self.paddingSpace : 0).isActive = true
		return paddingView
	}
}

public extension View {
	func padding(corners: [Corner] = [.leading, .trailing, .top, .bottom], paddingSpace: CGFloat = 10) -> PaddingView<Self>{
		return PaddingView(paddingCorners: corners, paddingSpace: paddingSpace, underlyingView: self)
	}
}
