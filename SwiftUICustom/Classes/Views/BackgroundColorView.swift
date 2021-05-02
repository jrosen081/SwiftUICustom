//
//  BackgroundColorView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct BackgroundColorView<Content: View>: View {
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        color.hash(into: &hasher)
        content._hash(into: &hasher, environment: environment)
    }
    
    public func _isEqual(toSameType other: BackgroundColorView<Content>, environment: EnvironmentValues) -> Bool {
        self.color == other.color && self.content._isEqual(to: other.content, environment: environment)
    }
        
	let color: UIColor
	let content: Content
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = SwiftUIView(frame: .zero)
		let contentView = content.__toUIView(enclosingController: enclosingController, environment: environment)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(contentView)
		NSLayoutConstraint.activate([
			view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			view.topAnchor.constraint(equalTo: contentView.topAnchor)
		])
		view.backgroundColor = color
		return view
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		view.backgroundColor = self.color
		self.content._redraw(view: view.subviews[0], controller: controller, environment: environment)
	}
}

public extension View {
	func background(_ color: UIColor) -> BackgroundColorView<Self> {
		return BackgroundColorView(color: color, content: self)
	}
}
