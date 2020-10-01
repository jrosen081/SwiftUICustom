//
//  PaddingView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct Corner: OptionSet {
	public let rawValue: Int
	
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
	
	public static let leading = Corner(rawValue: 1)
	public static let trailing = Corner(rawValue: 2)
	public static let top = Corner(rawValue: 4)
	public static let bottom = Corner(rawValue: 8)
	public static let all: Corner = [.leading, .trailing, .top, .bottom]
}

public struct PaddingView<Content: View>: View {
	let paddingCorners: Corner
	let paddingSpace: CGFloat
	let underlyingView: Content
	
	
	public var body: Content {
		return self.underlyingView
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let paddingView = PaddingUIView()
		let underlyingUIView = self.underlyingView.__toUIView(enclosingController: enclosingController, environment: environment)
		paddingView.addSubview(underlyingUIView)
		paddingView.translatesAutoresizingMaskIntoConstraints = false
		paddingView.bottomAnchor.constraint(equalTo: underlyingUIView.bottomAnchor, constant: paddingCorners.contains(.bottom) ? self.paddingSpace : 0).isActive = true
		paddingView.topAnchor.constraint(equalTo: underlyingUIView.topAnchor, constant: paddingCorners.contains(.top) ? -self.paddingSpace : 0).isActive = true
		paddingView.leadingAnchor.constraint(equalTo: underlyingUIView.leadingAnchor, constant: paddingCorners.contains(.leading) ? -self.paddingSpace : 0).isActive = true
		paddingView.trailingAnchor.constraint(equalTo: underlyingUIView.trailingAnchor, constant: paddingCorners.contains(.trailing) ? self.paddingSpace : 0).isActive = true
        paddingView.extraSize = CGSize(width: (paddingCorners.contains(.leading).toInt + paddingCorners.contains(.trailing).toInt) * self.paddingSpace, height: (paddingCorners.contains(.top).toInt + paddingCorners.contains(.bottom).toInt) * self.paddingSpace)
		return paddingView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.underlyingView._redraw(view: view.subviews[0], controller: controller, environment: environment)
	}
}

class PaddingUIView: SwiftUIView {
    var extraSize = CGSize.zero
    override var intrinsicContentSize: CGSize {
        return super.intrinsicContentSize + extraSize
    }
}

extension Bool {
    var toInt: CGFloat {
        return self ? 1 : 0
    }
}

extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

public extension View {
	func padding(corners: Corner = .all, paddingSpace: CGFloat = 10) -> PaddingView<Self>{
		return PaddingView(paddingCorners: corners, paddingSpace: paddingSpace, underlyingView: self)
	}
}
