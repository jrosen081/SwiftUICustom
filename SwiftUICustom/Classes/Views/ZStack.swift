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
        let buildingBlocks = contentBuilder.expanded()
        enclosingView.diff(buildingBlocks: buildingBlocks, controller: enclosingController, environment: environment, alignment: alignment)
		return enclosingView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		let viewProtocol = contentBuilder
		guard let zstackView = view as? ZStackView else { return }
        zstackView.diff(buildingBlocks: viewProtocol.expanded(), controller: controller, environment: environment, alignment: alignment)
	}
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        return expanded().map { $0._requestedSize(within: size, environment: environment) }.reduce(CGSize.zero, max(size1:size2:))
    }
    
    private func max(size1: CGSize, size2: CGSize) -> CGSize {
        return CGSize(width: Swift.max(size1.width, size2.width), height: Swift.max(size1.height, size2.height))
    }
}

class ZStackView: SwiftUIView {
    var buildingBlocks: [_BuildingBlock] = []
    
    func diff(buildingBlocks: [_BuildingBlock], controller: UIViewController, environment: EnvironmentValues, alignment: Alignment) {
        let diffResults = self.buildingBlocks.diff(other: buildingBlocks)
        let allAdditions = diffResults.additions.map { ($0, buildingBlocks[$0]._toUIView(enclosingController: controller, environment: environment), buildingBlocks[$0]) }
        let allDeletions = diffResults.deletion.map { ($0, self.subviews[$0]) }
        let moving = diffResults.moved.map { ($0.1, self.subviews[$0.0], buildingBlocks[$0.1]) }
        allDeletions.forEach { $0.1.removeFromSuperview() }
        let operationsToPerform = (allAdditions + moving).sorted(by: { $0.0 < $1.0 })
        operationsToPerform.forEach { (indexToInsert, uiView, buildingBlock) in
            uiView.removeFromSuperview()
            self.insertSubview(uiView, at: indexToInsert)
            self.setupSubview(underlyingView: uiView, alignment: alignment)
            buildingBlock._redraw(view: uiView, controller: controller, environment: environment)
        }
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
