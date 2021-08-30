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
        let stackView = SwiftUIStackView(arrangedSubviews: [], buildingBlocks: [])
        stackView.diff(body: view, controller: enclosingController, environment: environment)
        stackView.alignment = self.alignment.stackViewAlignment
        stackView.spacing = self.spacing
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let viewProtocol = viewCreator
        guard let stackView = view as? SwiftUIStackView else { return }
        stackView.diff(body: viewProtocol, controller: controller, environment: environment)
    }
}
