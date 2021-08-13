//
//  Button.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

public struct Button<ButtonContent: View>: View {
	let content: ButtonContent
	let onClick: () -> ()
    var updateControl: (ButtonView) -> Void = {_ in }
	
	public init(action: @escaping () -> (), @ViewBuilder content: () -> ButtonContent) {
		self.content = content()
		self.onClick = action
	}
	public var body: Self {
        return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var newEnvironment = environment
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? UIColor.systemBlue
        let actualThing = PrimitiveButtonStyleConfiguration(label: PrimitiveButtonStyleConfiguration.Label(buildingBlock: self.content), onClick: onClick, isNavigationLink: false)
        let base = environment.buttonStyle._makeBody(configuration: actualThing)
        environment.currentStateNode.buildingBlock = base
        let view = base._toUIView(enclosingController: enclosingController, environment: newEnvironment)
        environment.currentStateNode.uiView = view
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		let button = ButtonView(view: view, onClick: self.onClick)
        updateControl(button)
        if let cell = environment.cell {
            cell.onClick = self.onClick
            button.isUserInteractionEnabled = false
        }
        return button
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		var newEnvironment = environment
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? UIColor.systemBlue
        let actualThing = PrimitiveButtonStyleConfiguration(label: PrimitiveButtonStyleConfiguration.Label(buildingBlock: self.content), onClick: onClick, isNavigationLink: false)
        environment.buttonStyle._makeBody(configuration: actualThing)._redraw(view: view.subviews[0], controller: controller, environment: newEnvironment)
        if let cell = environment.cell {
            cell.onClick = self.onClick
        }
        guard let button = view as? ButtonView else { return }
        updateControl(button)
	}
}

protocol MenuCreator {
    @available(iOS 13, *)
    var menu: UIContextMenuConfiguration? { get }
}

class ButtonView: UIButton {
	var view: UIView
	var onClick: () -> ()
	var inList: Bool = false
	var alphaToChangeTo: CGFloat = 0.3
    var menuCreator: MenuCreator?
	
	init(view: UIView, onClick: @escaping () -> ()) {
		self.view = view
		self.onClick = onClick
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		setupView(view)
	}
	
	func setupView(_ view: UIView) {
		self.subviews.forEach {
			$0.constraints.forEach({ $0.isActive = false })
			$0.removeFromSuperview()
		}
		view.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(view)
		self.view = view
		self.setupFullConstraints(self.view, self)

	}
    
	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		self.view.alpha = self.alphaToChangeTo
		return super.beginTracking(touch, with: event)
	}
	
	override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		if !self.point(inside: touch.location(in: self), with: event) {
			self.cancelTracking(with: event)
			return false
		}
		return true
	}
	
	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)
		self.view.alpha = 1
		self.onClick()
	}
	
	override func cancelTracking(with event: UIEvent?) {
		super.cancelTracking(with: event)
		self.view.alpha = 1
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    override var intrinsicContentSize: CGSize {
        return self.subviews[0].intrinsicContentSize
    }
}

class TapSelectorHolder {
	let closure: (UITapGestureRecognizer) -> ()
	
	init(closure: @escaping (UITapGestureRecognizer) -> ()) {
		self.closure = closure
	}
	
	@objc func selected(tap: UITapGestureRecognizer) {
		self.closure(tap)
	}
}


