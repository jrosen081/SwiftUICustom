//
//  OverlayView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/23/20.
//

import Foundation

public struct OverlayView<Under: View, Over: View>: View {
    let under: Under
    let over: Over
    
    public var body: Self {
        return self
    }
    
    public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let container = OverlayUIKitView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        let under = self.under.__toUIView(enclosingController: enclosingController, environment: environment)
        container.addSubview(under)
        container.setupFullConstraints(container, under)
        let over = self.over.__toUIView(enclosingController: enclosingController, environment: environment)
        over.isUserInteractionEnabled = false
        container.addSubview(over)
        NSLayoutConstraint.activate([
            over.trailingAnchor.constraint(lessThanOrEqualTo: under.trailingAnchor),
            over.bottomAnchor.constraint(lessThanOrEqualTo: under.bottomAnchor),
            over.topAnchor.constraint(greaterThanOrEqualTo: under.topAnchor),
            over.leadingAnchor.constraint(greaterThanOrEqualTo: under.leadingAnchor),
        ])
        return container
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        self.under._redraw(view: view.subviews[0], controller: controller, environment: environment)
        self.over._redraw(view: view.subviews[1], controller: controller, environment: environment)
    }
}

class OverlayUIKitView: SwiftUIView {
    override var intrinsicContentSize: CGSize {
        return self.subviews[0].intrinsicContentSize
    }
    
    override func willExpand(in context: ExpandingContext) -> Bool {
        return self.subviews[0].willExpand(in: context)
    }
}

public extension View {
    func overlay<V: View>(_ over: V) -> OverlayView<Self, V> {
        return OverlayView(under: self, over: over)
    }
}
