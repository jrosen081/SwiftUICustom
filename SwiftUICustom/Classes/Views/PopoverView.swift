//
//  PopoverView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/10/20.
//

import Foundation

public struct PopoverView<PresentingView: View, Content: View>: View {
	let presentingView: PresentingView
	let contentCreator: Content
	let binding: Binding<Bool>
    
    public func _isEqual(toSameType other: PopoverView<PresentingView, Content>, environment: EnvironmentValues) -> Bool {
        presentingView._isEqual(to: other.presentingView, environment: environment) && contentCreator._isEqual(to: other.contentCreator, environment: environment) && binding.wrappedValue == other.binding.wrappedValue
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        presentingView._hash(into: &hasher, environment: environment)
        contentCreator._hash(into: &hasher, environment: environment)
        binding.wrappedValue.hash(into: &hasher)
    }
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = self.presentingView.__toUIView(enclosingController: enclosingController, environment: environment)
		if (self.binding.wrappedValue) {
			let controller = SwiftUIController(swiftUIView: self.contentCreator)
			controller.isShowing = self.binding
			enclosingController.present(controller, animated: true)
		}
		return view
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.presentingView._redraw(view: view, controller: controller, environment: environment)
		if (!binding.wrappedValue) {
			controller.presentedViewController?.dismiss(animated: true, completion: nil)
		} else if let presented = controller.presentedViewController as? SwiftUIController<Content> {
            presented.swiftUIView = self.contentCreator
		} else {
			controller.presentedViewController?.dismiss(animated: true, completion: nil)
			let internalController = SwiftUIController(swiftUIView: self.contentCreator)
			internalController.isShowing = self.binding
			controller.present(internalController, animated: true)
		}
	}
}


public extension View {
	func popover<Content: View>(isShowing: Binding<Bool>, content: () -> Content) -> PopoverView<Self, Content> {
		return PopoverView(presentingView: self, contentCreator: content(), binding: isShowing)
	}
}
