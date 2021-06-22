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
        let underlyingViews = buildingBlocks.map { $0._toUIView(enclosingController: enclosingController, environment: environment) }
		let stackView = SwiftUIStackView(arrangedSubviews: underlyingViews, context: .horizontal, buildingBlocks: buildingBlocks)
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
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        size // TODO: this
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

class SwiftUIStackView: UIStackView {
    var buildingBlocks: [_BuildingBlock]
    let context: ExpandingContext
    
    func diff(buildingBlocks: [_BuildingBlock], controller: UIViewController, environment: EnvironmentValues) {
        let diffResults = self.buildingBlocks.diff(other: buildingBlocks)
        let allAdditions = diffResults.additions.map { ($0, buildingBlocks[$0]._toUIView(enclosingController: controller, environment: environment), buildingBlocks[$0]) }
        let allDeletions = diffResults.deletion.map { ($0, self.arrangedSubviews[$0]) }
        let moving = diffResults.moved.map { ($0.1, self.arrangedSubviews[$0.0], buildingBlocks[$0.1]) }
        allDeletions.forEach { $0.1.removeFromSuperview() }
        let operationsToPerform = (allAdditions + moving).sorted(by: { $0.0 < $1.0 })
        operationsToPerform.forEach { (indexToInsert, uiView, buildingBlock) in
            self.removeArrangedSubview(uiView)
            self.insertArrangedSubview(uiView, at: indexToInsert)
            buildingBlock._redraw(view: uiView, controller: controller, environment: environment)
        }
        self.buildingBlocks = buildingBlocks
    }
    
	override func willExpand(in context: ExpandingContext) -> Bool {
		return self.arrangedSubviews.contains(where: { $0.willExpand(in: context)} )
	}
	
	override var intrinsicContentSize: CGSize {
        let expandedSign = UIView.layoutFittingExpandedSize.width
		return self.arrangedSubviews.map(\.intrinsicContentSize)
			.reduce(CGSize.zero, {
                if self.context == .horizontal {
                    if $0.width == expandedSign || $1.width == expandedSign {
                        return CGSize(width: expandedSign, height: max($0.height, $1.height))
                    }
                    return CGSize(width: $0.width + $1.width, height: max($0.height, $1.height))
                } else {
                    if $0.height == expandedSign || $1.height == expandedSign {
                        return CGSize(width: max($0.width, $1.width), height: expandedSign)
                    }
                    return CGSize(width: max($0.width, $1.width), height: $0.height + $1.height)
                }
			})
	}
	
    init(arrangedSubviews: [UIView], context: ExpandingContext, buildingBlocks: [_BuildingBlock]) {
        self.buildingBlocks = buildingBlocks
        self.context = context
		super.init(frame: .zero)
		let actualViews = arrangedSubviews.flatMap {
			($0 as? InternalLazyCollatedView)?.arrangedSubviews ?? [$0]
		}
		actualViews.forEach {
			self.addArrangedSubview($0)
			if let horizontal = $0 as? ExpandingView {
				horizontal.context = [context]
			}
		}
		
		// All Expanding Views need to have the same size
		_ = actualViews.compactMap { $0 as? ExpandingView }
			.reduce(nil, { (view: UIView?, expandingView) -> UIView? in
				if let view = view {
					view.heightAnchor.constraint(equalTo: expandingView.heightAnchor).isActive = true
					view.widthAnchor.constraint(equalTo: expandingView.widthAnchor).isActive = true
				}
				return expandingView
			})
		
		// If there is no expanding views, fill proportionally, else fill
		if !self.willExpand(in: context) {
			self.distribution = .fillProportionally
		}
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
