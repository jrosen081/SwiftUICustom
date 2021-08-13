//
//  Spacer.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct Spacer: View {
	public var body: Self {
		return self
	}
	
	public init() { }
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		return ExpandingView()
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		// Do nothing
	}
}

internal class ExpandingView: UIView {
    
//    override var intrinsicContentSize: CGSize {
//        UIView.layoutFittingExpandedSize
//    }
    
    
	init() {
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		setContentCompressionResistancePriority(.init(1), for: .horizontal)
		setContentCompressionResistancePriority(.init(1), for: .vertical)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
