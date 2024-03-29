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
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        environment.currentStateNode.buildingBlock = self.presentingView
		let view = self.presentingView._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = view
		if (self.binding.wrappedValue) {
			let controller = SwiftUIController(swiftUIView: self.contentCreator)
            controller.environment = environment
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
            presented.environment = environment
            presented.swiftUIView = self.contentCreator
		} else {
			controller.presentedViewController?.dismiss(animated: true, completion: nil)
			let internalController = SwiftUIController(swiftUIView: self.contentCreator)
            internalController.environment = environment
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
