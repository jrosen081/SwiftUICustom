//
//  EnvironmentUpdatingView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct EnvironmentUpdatingView<Content: View>: View {
	let content: Content
	let updates: (inout EnvironmentValues) -> ()
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let updates = environment.withUpdates(self.updates)
		if #available(iOS 13.0, *) {
			enclosingController.overrideUserInterfaceStyle = updates.colorScheme == .dark ? .dark : .light
			enclosingController.navigationController?.overrideUserInterfaceStyle = updates.colorScheme == .dark ? .dark : .light
		}
		return self.content._toUIView(enclosingController: enclosingController, environment: updates)
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.content._redraw(view: view, controller: controller, environment: environment.withUpdates(self.updates))
	}
}

public extension View {
	func font(_ font: UIFont) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0.font = font
		})
	}
	
	func lineLimit(_ limit: Int?) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0.lineLimit = limit
		})
	}
	
	func lineSpacing(_ spacing: CGFloat) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0.lineSpacing = spacing
		})
	}
	
	func multilineTextAlignment(_ alignment: NSTextAlignment) -> EnvironmentUpdatingView<Self> {
		 return EnvironmentUpdatingView(content: self, updates: {
			$0.multilineTextAlignment = alignment
		 })
	}

	func minimumScaleFactor(_ scale: CGFloat) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
		   $0.minimumScaleFactor = scale
		})
	}
	
	func allowsTightening(_ tightening: Bool) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
		   $0.allowsTightening = tightening
		})
	}
	
	func textContentType(_ textContentType: UITextContentType?) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0.textContentType = textContentType
		})
	}

	func environmentObject<Object: ObservableObject>(_ object: Object) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0[EnvironmentObjectGetter<Object>.self] = object
		})
	}
	
	func environment<Object>(_ keyPath: WritableKeyPath<EnvironmentValues, Object>, _ object: Object) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: { (environment: inout EnvironmentValues) in
			environment[keyPath: keyPath] = object
		})
	}
	
	func animation(_ animation: Animation) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0.currentAnimation = animation
		})
	}
}
