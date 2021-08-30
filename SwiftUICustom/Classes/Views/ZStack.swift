//
//  ZStack.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct ZStack<Content: View>: View {
	let contentBuilder: Content
	let alignment: Alignment
	
	public init(alignment: Alignment = .center, @ViewBuilder contentBuilder: () -> Content) {
		self.contentBuilder = contentBuilder()
		self.alignment = alignment
	}
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let enclosingView = ZStackView(frame: .zero)
		enclosingView.translatesAutoresizingMaskIntoConstraints = false
        enclosingView.diff(body: contentBuilder, controller: enclosingController, environment: environment, alignment: alignment)
		return enclosingView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let zstackView = view as? ZStackView else { return }
        zstackView.diff(body: contentBuilder, controller: controller, environment: environment, alignment: alignment)
	}
}

class ZStackView: SwiftUIView {
    var buildingBlocks: [_BuildingBlock] = []
    
    func diff(body: _BuildingBlock, controller: UIViewController, environment: EnvironmentValues, alignment: Alignment) {
        let bodySequence = body._makeSequence(currentNode: environment.currentStateNode)
        let buildingBlockAndNodes = (0..<bodySequence.count).map { bodySequence.viewGetter($0, environment.currentStateNode) }
        let buildingBlocks = buildingBlockAndNodes.map(\.0)
        let newChildren = buildingBlockAndNodes.map(\.1)
        let currentNode = environment.currentStateNode
        let diffResults = self.buildingBlocks.diff(other: buildingBlocks)
        let allDeletions = diffResults.deletion.map { ($0, self.subviews[$0]) }
        let moving = diffResults.moved.map { ($0.1,
                                              self.subviews[$0.0],
                                              buildingBlocks[$0.1],
                                              newChildren[$0.1]) }
        allDeletions.forEach { $0.1.removeFromSuperview() }
        let allAdditions = diffResults.additions.map { (index: Int) -> (Int, UIView, _BuildingBlock, DOMNode) in
            let domNode = newChildren[index]
            var newEnvironment = environment
            newEnvironment.currentStateNode = domNode
            let view = buildingBlocks[index]._toUIView(enclosingController: controller, environment: newEnvironment)
            domNode.uiView = view
            return (index, view, buildingBlocks[index], domNode)
        }
        let operationsToPerform = (allAdditions + moving).sorted(by: { $0.0 < $1.0 })
        operationsToPerform.forEach { (indexToInsert, uiView, buildingBlock, node) in
            let shouldRedraw = uiView.superview != nil
            uiView.removeFromSuperview()
            self.insertSubview(uiView, at: indexToInsert)
            self.setupSubview(underlyingView: uiView, alignment: alignment)
            var newEnvironment = environment
            newEnvironment.currentStateNode = node
            if shouldRedraw {
                buildingBlock._redraw(view: uiView, controller: controller, environment: newEnvironment)
            }
        }
        currentNode.uiView = self
        self.buildingBlocks = buildingBlocks
    }
    
    func setupSubview(underlyingView: UIView, alignment: Alignment) {
        NSLayoutConstraint.activate([
            alignment.horizontalAlignment.toAnchor(inView: underlyingView).constraint(equalTo: alignment.horizontalAlignment.toAnchor(inView: self)),
            alignment.verticalAlignment.toAnchor(inView: underlyingView).constraint(equalTo: alignment.verticalAlignment.toAnchor(inView: self)),
            self.widthAnchor.constraint(greaterThanOrEqualTo: underlyingView.widthAnchor, multiplier: 1),
            self.heightAnchor.constraint(greaterThanOrEqualTo: underlyingView.heightAnchor, multiplier: 1),
        ])
    }
}
