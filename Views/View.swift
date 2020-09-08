//
//  View.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import UIKit

public protocol View: BuildingBlock {
	associatedtype Content: View
	var body: Content { get }
}

public protocol BuildingBlock {
	func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView
	func redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues)
}

extension View {
	public func redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.body.redraw(view: view, controller: controller, environment: environment)
	}
	
	public func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let mirror = Mirror(reflecting: self)
		mirror.children.map { $0.value }
			.compactMap { $0 as? EnvironmentNeeded }
			.forEach { $0.environment = environment }
		if let controller = enclosingController as? UpdateDelegate {
			mirror.children.map { $0.value }
				.compactMap { $0 as? Redrawable }
				.forEach { $0.addListener(controller) }
		}
		return self.body.toUIView(enclosingController: enclosingController, environment: environment)
	}
}

public extension View {
	func modifier<T>(_ modifier: T) -> ModifiedContent<Self, T> {
		return ModifiedContent(content: self, modification: modifier)
	}
}

public struct ModifiedContent<Content: View, Modification: ViewModifier> {
	let content: Content
	let modification: Modification
	
	var body: Modification.Body {
		self.modification.body(content: self.content)
	}
}

public protocol ViewModifier {
	associatedtype Body
	func body<Content: View>(content: Content) -> Self.Body
}
