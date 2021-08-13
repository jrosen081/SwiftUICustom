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
        let buildingBlocks = view.expanded()
		let stackView = SwiftUIStackView(arrangedSubviews: [], buildingBlocks: [])
        stackView.diff(buildingBlocks: buildingBlocks, controller: enclosingController, environment: environment)
		stackView.alignment = self.alignment.stackViewAlignment
		stackView.spacing = self.spacing
		stackView.axis = .horizontal
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		let viewProtocol = viewCreator
        guard let stackView = view as? SwiftUIStackView else { return }
        stackView.diff(buildingBlocks: viewProtocol.expanded(), controller: controller, environment: environment)
	}
}

extension Array where Element == _BuildingBlock {
	func expanded() -> [Element] {
		return self.flatMap( { (val) -> [Element] in
			if let expandable = val as? Expandable {
				return expandable.expanded()
			}
			return [val]
		})
	}
}

// TODO: This
class SwiftUIStackView: UIStackView {
    var buildingBlocks: [_BuildingBlock]
    
    func diff(buildingBlocks: [_BuildingBlock], controller: UIViewController, environment: EnvironmentValues) {
        let currentNode = environment.currentStateNode
        let allChildren = currentNode.childNodes
        let diffResults = self.buildingBlocks.diff(other: buildingBlocks)
        let allDeletions = diffResults.deletion.map { ($0, self.arrangedSubviews[$0]) }
        let moving = diffResults.moved.map { ($0.1, self.arrangedSubviews[$0.0], buildingBlocks[$0.1], allChildren[$0.0]) }
        allDeletions.forEach { $0.1.removeFromSuperview() }
        let allAdditions = diffResults.additions.map { (index: Int) -> (Int, UIView, _BuildingBlock, DOMNode) in
            let domNode = DOMNode(environment: environment, viewController: controller, buildingBlock: buildingBlocks[index])
            var newEnvironment = environment
            newEnvironment.currentStateNode = domNode
            let view = buildingBlocks[index]._toUIView(enclosingController: controller, environment: newEnvironment)
            domNode.uiView = view
            return (index, view, buildingBlocks[index], domNode)
        }
        let operationsToPerform = (allAdditions + moving).sorted(by: { $0.0 < $1.0 })
        var newChildren: [DOMNode] = []
        operationsToPerform.forEach { (indexToInsert, uiView, buildingBlock, node) in
            self.removeArrangedSubview(uiView)
            self.insertArrangedSubview(uiView, at: indexToInsert)
            var newEnvironment = environment
            newEnvironment.currentStateNode = node
            newChildren.append(node)
            buildingBlock._redraw(view: uiView, controller: controller, environment: newEnvironment)
        }
        currentNode.childNodes = newChildren
        self.buildingBlocks = buildingBlocks
    }
	
    init(arrangedSubviews: [UIView], buildingBlocks: [_BuildingBlock]) {
        self.buildingBlocks = buildingBlocks
		super.init(frame: .zero)
		let actualViews = arrangedSubviews
		actualViews.forEach {
			self.addArrangedSubview($0)
		}
        self.distribution = .fillProportionally
    }
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func == (lhs: SwiftUIStackView, rhs: SwiftUIStackView) -> Bool {
		return lhs.arrangedSubviews == rhs.arrangedSubviews
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
