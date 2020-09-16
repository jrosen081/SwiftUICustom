//
//  VStack.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

public struct VStack<Content: View>: View {
	let viewCreator: Content
	let spacing: CGFloat
	let alignment: HorizontalAlignment
	 
	public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder _ viewCreator:  () -> Content) {
		self.viewCreator = viewCreator()
		self.spacing = spacing ?? 5
		self.alignment = alignment
	}
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = viewCreator
		let uiView = view._toUIView(enclosingController: enclosingController, environment: environment)
		(uiView as? InternalLazyCollatedView)?.expand()
		let stackView = SwiftUIStackView(arrangedSubviews: (uiView as? InternalCollatedView)?.underlyingViews ?? [uiView], context: .vertical)
		stackView.alignment = self.alignment.stackViewAlignment
		stackView.axis = .vertical
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = self.spacing
		return stackView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		let viewProtocol = viewCreator
		guard let stackView = view as? UIStackView, let buildingBlockCreator = viewProtocol as? BuildingBlockCreator else { return }
		zip(stackView.arrangedSubviews, buildingBlockCreator.toBuildingBlocks().expanded()).forEach {
			$1._redraw(view: $0, controller: controller, environment: environment)
		}
	}
}
