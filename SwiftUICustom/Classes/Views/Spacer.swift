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
        
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        size
    }
}

@objc internal enum ExpandingContext: Int {
	case horizontal = 0, vertical = 1
	
	var toStackDistribution: NSLayoutConstraint.Axis {
		self == .horizontal ? .horizontal : .vertical
	}
}

internal class ExpandingView: UIView {
    
    func withContext(_ context: ExpandingContext) -> Self {
        self.context = [context]
        return self
    }
	
	override func willExpand(in context: ExpandingContext) -> Bool {
		return self.context.contains(context)
	}
	
	init() {
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		setContentCompressionResistancePriority(.init(240), for: .horizontal)
		setContentCompressionResistancePriority(.init(240), for: .vertical)
		setContentHuggingPriority(.init(240), for: .horizontal)
		setContentHuggingPriority(.init(240), for: .vertical)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var context: [ExpandingContext] = [] {
		didSet {
			invalidateIntrinsicContentSize()
		}
	}
	
	override var intrinsicContentSize: CGSize {
		let expanded = UIView.layoutFittingExpandedSize
		var size = CGSize.zero
		if context.contains(.horizontal) {
			size = CGSize(width: expanded.width, height: 0)
		}
		if context.contains(.vertical) {
			size = CGSize(width: size.width, height: expanded.height)
		}
		return size
	}
	
	static func == (lhs: ExpandingView, rhs: ExpandingView) -> Bool {
		return lhs.context == rhs.context
	}
}
