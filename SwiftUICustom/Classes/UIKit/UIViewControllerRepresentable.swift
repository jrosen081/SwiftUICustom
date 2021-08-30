//
//  UIViewControllerRepresentable.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/12/21.
//

import Foundation

public protocol UIViewControllerRepresentable: View where Self.Content == Never {
    associatedtype UIViewControllerType: UIViewController
    associatedtype Coordinator = Void
    typealias Context = UIViewControllerRepresentableContext<Self>
    func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType
    func updateUIViewController(_ uiViewController: Self.UIViewControllerType, context: Self.Context)
    func makeCoordinator() -> Self.Coordinator
    static func dismantleViewController(_ uiViewController: Self.UIViewControllerType)
}

public extension UIViewControllerRepresentable where Coordinator == Void {
    func makeCoordinator() -> Self.Coordinator {
        return ()
    }
}

public extension UIViewControllerRepresentable {
    var body: Content {
        fatalError()
    }
    
    func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let `self` = _StateNode(view: self, node: environment.currentStateNode).updatedValue()
        let coordinator = self.makeCoordinator()
        let myViewController = self.makeUIViewController(context: Self.Context(environment: environment, coordinator: coordinator))
        let mainView = ControllerRepresentableView<Self>(coordinator: coordinator, controller: myViewController)
        myViewController.view.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(myViewController.view)
        mainView.setupFullConstraints(mainView, myViewController.view)
        enclosingController.addChild(myViewController)
        return mainView
    }
    
    func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        guard let view = view as? ControllerRepresentableView<Self> else { return }
        let `self` = _StateNode(view: self, node: environment.currentStateNode).updatedValue()
        self.updateUIViewController(view.controller, context: Context(environment: environment, coordinator: view.coordinator))
    }
    
    static func dismantleViewController(_ uiViewController: Self.UIViewControllerType) { }
}

public struct UIViewControllerRepresentableContext<Representable> where Representable : UIViewControllerRepresentable {
    public let environment: EnvironmentValues
    public let coordinator: Representable.Coordinator
}

class ControllerRepresentableView<Repr: UIViewControllerRepresentable>: UIView {
    let coordinator: Repr.Coordinator
    let controller: Repr.UIViewControllerType
    
    init(coordinator: Repr.Coordinator, controller: Repr.UIViewControllerType) {
        self.coordinator = coordinator
        self.controller = controller
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func removeFromSuperview() {
        Repr.dismantleViewController(self.controller)
        super.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
