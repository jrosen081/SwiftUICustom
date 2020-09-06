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
	func toUIView(enclosingController: UIViewController) -> UIView
}

extension View {
	public func toUIView(enclosingController: UIViewController) -> UIView {
		if let controller = enclosingController as? UpdateDelegate {
			let mirror = Mirror(reflecting: self)
			mirror.children.map { $0.value }
				.compactMap { $0 as? Redrawable }
				.forEach { $0.addListener(controller) }
		}
		return self.body.toUIView(enclosingController: enclosingController)
	}
	
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
