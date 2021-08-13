//
//  FrameView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct FrameView<Content: View>: View {
	let size: CGSize
	let content: Content
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        environment.currentStateNode.buildingBlock = content
		let view = content._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = view
        let swiftUIView = FixedSizeUIView(size: self.size)
        swiftUIView.translatesAutoresizingMaskIntoConstraints = false
        swiftUIView.addSubview(view)
        view.setupFullConstraints(view, swiftUIView)
		return swiftUIView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        guard let sizeView = view as? FixedSizeUIView else { return }
        sizeView.size = self.size
        sizeView.invalidateIntrinsicContentSize()
        self.content._redraw(view: view.subviews[0], controller: controller, environment: environment)
	}
}

class FixedSizeUIView: UIView {
    var size: CGSize {
        didSet {
            self.widthConstraint?.constant = size.width
            self.heightConstraint?.constant = size.height
        }
    }
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    override var intrinsicContentSize: CGSize {
        return size
    }
    
    init(size: CGSize) {
        self.size = size
        super.init(frame: .zero)
        self.widthConstraint = self.widthAnchor.constraint(equalToConstant: size.width)
        self.widthConstraint?.isActive = true
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: size.height)
        self.heightConstraint?.isActive = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension View {
	func frame(width: CGFloat, height: CGFloat) -> FrameView<Self> {
		return FrameView(size: CGSize(width: width, height: height), content: self)
	}
}
