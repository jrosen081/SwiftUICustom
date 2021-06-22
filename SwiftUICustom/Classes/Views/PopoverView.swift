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
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        presentingView._requestedSize(within: size, environment: environment)
    }
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = self.presentingView._toUIView(enclosingController: enclosingController, environment: environment)
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
