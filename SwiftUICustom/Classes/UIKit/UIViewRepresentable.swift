//
//  UIViewRepresentable.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/10/20.
//

import Foundation

public protocol UIViewRepresentable: View where Self.Content == Never {
	typealias Context = UIViewRepresentableContext<Self>
	associatedtype UIViewType : UIView
	associatedtype Coordinator = Never
	func makeUIView(context: Self.Context) -> Self.UIViewType
	func updateUIView(_ view: Self.UIViewType, context: Self.Context)
	func makeCoordinator() -> Self.Coordinator
    static func dismantleUIView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator)
}

public extension UIViewRepresentable where Self.Coordinator == Swift.Void {
    func makeCoordinator() -> Swift.Void { return }
}

extension UIViewRepresentable {
    public static func dismantleUIView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator) { }
    
    public var _viewInfo: _ViewInfo {
        _ViewInfo(isBase: true, baseBlock: self, layoutPriority: .firm)
    }
    
	public var body: Never {
        fatalError()
	}
    
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let swiftUIView = SwiftUIViewRepresentable<Self>(coordinator: self.makeCoordinator())
        let underlyingView = _StateNode(view: self, node: environment.currentStateNode).updatedValue().makeUIView(context: UIViewRepresentableContext(coordinatorHolder: swiftUIView.getCoordinator, environment: environment))
		swiftUIView.addSubview(underlyingView)
		swiftUIView.setupFullConstraints(swiftUIView, underlyingView)
		return swiftUIView
	}
	
	public func _redraw(view internalView: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let view = internalView as? SwiftUIViewRepresentable<Self>, let actualView = view.subviews[0] as? Self.UIViewType else { return }
        _StateNode(view: self, node: environment.currentStateNode).updatedValue().updateUIView(actualView, context: UIViewRepresentableContext(coordinatorHolder: view.getCoordinator, environment: environment))
	}
}

internal class SwiftUIViewRepresentable<Representable: UIViewRepresentable>: SwiftUIView {
    typealias Coordinator = Representable.Coordinator
    private enum CoordinatorHolder {
        case uninitialized(() -> Coordinator)
        case coordinator(Coordinator)
    }
    
	private var coordinator: CoordinatorHolder
    
    func getCoordinator() -> Coordinator {
        let coordinator: Coordinator
        switch self.coordinator {
        case .uninitialized(let creator):
            coordinator = creator()
        case .coordinator(let value):
            coordinator = value
        }
        self.coordinator = .coordinator(coordinator)
        return coordinator
    }
    
	init(coordinator: @autoclosure @escaping () -> Coordinator) {
        self.coordinator = .uninitialized(coordinator)
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    override func removeFromSuperview() {
        Representable.dismantleUIView(self.subviews[0] as! Representable.UIViewType, coordinator: self.getCoordinator())
        super.removeFromSuperview()
    }
}

public struct UIViewRepresentableContext<Context> where Context: UIViewRepresentable {
    let coordinatorHolder: () -> Context.Coordinator
    public var coordinator: Context.Coordinator {
        coordinatorHolder()
    }
	public let environment: EnvironmentValues
}
