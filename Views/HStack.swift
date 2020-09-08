//
//  HStack.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct HStack<Content: View>: View {
	let viewCreator: () -> Content
	let alignment: VerticalAlignment
	let spacing: CGFloat
	
	public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder _ viewCreator: @escaping () -> Content) {
		self.viewCreator = viewCreator
		self.alignment = alignment
		self.spacing = spacing ?? 5
	}
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = viewCreator()
		let uiView = view.toUIView(enclosingController: enclosingController, environment: environment)
		(uiView as? InternalLazyCollatedView)?.expand()
		let stackView = SwiftUIStackView(arrangedSubviews: (uiView as? InternalCollatedView)?.underlyingViews ?? [uiView], context: .horizontal)
		stackView.alignment = self.alignment.stackViewAlignment
		stackView.spacing = self.spacing
		stackView.axis = .horizontal
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}
	
	public func redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		let viewProtocol = viewCreator()
		guard let stackView = view as? UIStackView, let buildingBlockCreator = viewProtocol as? BuildingBlockCreator else { return }
		zip(stackView.arrangedSubviews, buildingBlockCreator.toBuildingBlocks().expanded()).forEach {
			$1.redraw(view: $0, controller: controller, environment: environment)
		}
	}
}

extension Array where Element == BuildingBlock {
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
	
	override var willExpand: Bool {
		return self.arrangedSubviews.contains(where: \.willExpand)
	}
	
	init(arrangedSubviews: [UIView], context: ExpandingContext) {
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
		if !self.willExpand {
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
