//
//  UIViewRepresentable.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/10/20.
//

import Foundation

public protocol UIViewRepresentable: View where Self.Content == Self {
	typealias Context = UIViewRepresentableContext<Self>
	associatedtype UIViewType : UIView
	associatedtype Coordinator
	func makeUIView(context: Self.Context) -> Self.UIViewType
	func updateUIView(_ view: Self.UIViewType, context: Self.Context)
	func makeCoordinator() -> Self.Coordinator
}

extension UIViewRepresentable where Self.Coordinator == Never {
    public func makeCoordinator() -> Never { Never() }
}

extension UIViewRepresentable {
	public var body: Self {
        self
	}
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        self.makeUIView(context: UIViewRepresentableContext(coordinator: self.makeCoordinator(), environment: EnvironmentValues())).sizeThatFits(size)
    }
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let swiftUIView = SwiftUIViewRepresentable(coordinator: self.makeCoordinator())
		let underlyingView = self.makeUIView(context: UIViewRepresentableContext(coordinator: swiftUIView.coordinator, environment: environment))
		swiftUIView.addSubview(underlyingView)
		swiftUIView.setupFullConstraints(swiftUIView, underlyingView)
		return swiftUIView
	}
	
	public func _redraw(view internalView: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let view = internalView as? SwiftUIViewRepresentable<Self.Coordinator>, let actualView = view.subviews[0] as? Self.UIViewType else { return }
		self.updateUIView(actualView, context: UIViewRepresentableContext(coordinator: view.coordinator, environment: environment))
	}
    
    public func _isEqual(toSameType other: Self, environment: EnvironmentValues) -> Bool {
        return true
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        0.hash(into: &hasher)
    }
}

internal class SwiftUIViewRepresentable<Coordinator>: SwiftUIView {
	let coordinator: Coordinator
	init(coordinator: Coordinator) {
		self.coordinator = coordinator
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

public struct UIViewRepresentableContext<Context> where Context: UIViewRepresentable {
	let coordinator: Context.Coordinator
	var environment: EnvironmentValues
}


public struct Never: View {
	public var body: Self {
		fatalError()
	}
}
