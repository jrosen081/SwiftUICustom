//
//  EmptyView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/7/20.
//

import Foundation

public struct EmptyView: View {
	public init() {}
	
	public var body: EmptyView {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		return ShrinkingView()
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		// Do nothing
	}
}

class ShrinkingView: UIView {
	override var intrinsicContentSize: CGSize {
		return .zero
	}
	
	override class var requiresConstraintBasedLayout: Bool {
		return true
	}
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
