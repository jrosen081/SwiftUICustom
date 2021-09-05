//
//  HStack.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct HStack<Content: View>: View {
	let viewCreator: Content
	let alignment: VerticalAlignment
	let spacing: CGFloat
	
	public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder _ viewCreator: () -> Content) {
		self.viewCreator = viewCreator()
		self.alignment = alignment
		self.spacing = spacing ?? 5
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
		stackView.axis = .horizontal
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		let viewProtocol = viewCreator
        guard let stackView = view as? SwiftUIStackView else { return }
        stackView.diff(body: viewProtocol, controller: controller, environment: environment)
        stackView.spacing = self.spacing
        stackView.alignment = self.alignment.stackViewAlignment
	}
}

// TODO: This
class SwiftUIStackView: UIStackView {
    var buildingBlocks: [_BuildingBlock]
    
    func diff(body: _BuildingBlock, controller: UIViewController, environment: EnvironmentValues) {
        let buildingBlockAndNodes = body._makeSequence(currentNode: environment.currentStateNode).expanded(node: environment.currentStateNode)
        let buildingBlocks = buildingBlockAndNodes.map(\.0)
        let newChildren = buildingBlockAndNodes.map(\.1)
        let currentNode = environment.currentStateNode
        let diffResults = self.buildingBlocks.diff(other: buildingBlocks)
        let allDeletions = diffResults.deletion.map { ($0, self.arrangedSubviews[$0]) }
        let moving = diffResults.moved.map { ($0.1,
                                              self.arrangedSubviews[$0.0],
                                              buildingBlocks[$0.1],
                                              newChildren[$0.1]) }
        allDeletions.forEach { $0.1.removeFromSuperview() }
        let allAdditions = diffResults.additions.map { (index: Int) -> (Int, UIView, _BuildingBlock, DOMNode) in
            let (swiftUIView, domNode) = buildingBlockAndNodes[index]
            var newEnvironment = domNode.environment
            newEnvironment.currentStateNode = domNode
            let view = swiftUIView.buildingBlock._toUIView(enclosingController: controller, environment: newEnvironment)
            domNode.uiView = view
            return (index, view, swiftUIView, domNode)
        }
        let operationsToPerform = (allAdditions + moving).sorted(by: { $0.0 < $1.0 })
        operationsToPerform.forEach { (indexToInsert, uiView, buildingBlock, node) in
            let shouldRedraw = uiView.superview != nil
            self.removeArrangedSubview(uiView)
            self.insertArrangedSubview(uiView, at: indexToInsert)
            var newEnvironment = environment
            newEnvironment.currentStateNode = node
            if shouldRedraw {
                buildingBlock._redraw(view: uiView, controller: controller, environment: newEnvironment)
            }
        }
        currentNode.uiView = self
        self.buildingBlocks = buildingBlocks
    }
	
    init(arrangedSubviews: [UIView], buildingBlocks: [_BuildingBlock]) {
        self.buildingBlocks = buildingBlocks
		super.init(frame: .zero)
		let actualViews = arrangedSubviews
		actualViews.forEach {
			self.addArrangedSubview($0)
		}
        self.distribution = .equalCentering
    }
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    override var axis: NSLayoutConstraint.Axis {
        didSet {
            setContentCompressionResistancePriority(.defaultHigh, for: axis == .horizontal ? .vertical : .horizontal)
        }
    }
}

extension Array {
	func groupBy<T: Hashable>(mapper: (Element) -> T) -> [T: [Element]] {
		var returningMap: [T: [Element]] = [:]
		self.map { (mapper($0), $0) }
			.forEach { returningMap[$0.0] = returningMap[$0.0, default: []] + [$0.1] }
		return returningMap
	}
}
