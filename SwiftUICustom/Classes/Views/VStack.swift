//
//  VStack.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

public struct VStack<Content: View>: View {
    
    public func _isEqual(toSameType other: VStack<Content>, environment: EnvironmentValues) -> Bool {
        self.alignment == other.alignment && self.spacing == other.spacing && self.viewCreator._isEqual(to: other.viewCreator, environment: environment)
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        alignment.hash(into: &hasher)
        spacing.hash(into: &hasher)
        viewCreator._hash(into: &hasher, environment: environment)
    }
    
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
	
    public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let view = viewCreator
        let buildingBlocks = view.expanded()
        let underlyingViews = buildingBlocks.map { $0.__toUIView(enclosingController: enclosingController, environment: environment) }
        let stackView = SwiftUIStackView(arrangedSubviews: underlyingViews, context: .vertical, buildingBlocks: buildingBlocks)
        stackView.alignment = self.alignment.stackViewAlignment
        stackView.spacing = self.spacing
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let viewProtocol = viewCreator
        guard let stackView = view as? SwiftUIStackView else { return }
        stackView.diff(buildingBlocks: viewProtocol.expanded(), controller: controller, environment: environment)
    }
}
