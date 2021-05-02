//
//  InternalCollatedView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

class InternalCollatedView: SwiftUIStackView {
	
	var underlyingViews: [UIView] {
		return self.arrangedSubviews
	}
	
    init(underlyingViews: [UIView], buildingBlocks: [_BuildingBlock]) {
		super.init(arrangedSubviews: underlyingViews, context: .vertical, buildingBlocks: buildingBlocks)
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class InternalLazyCollatedView: InternalCollatedView {
	var count: Int {
		return self.viewCount.map { $0.1 }.reduce(0, +)
	}
	var viewCount: [(UIView, Int)]
	
	subscript(index: Int) -> UIView {
		let (view, internalIndex) = self.viewCount.flatMap { tuple in
			(0..<tuple.1).map { index in (tuple.0, index) }
			}[index]
		return (view as? InternalLazyCollatedView)?[internalIndex] ?? view
	}
	
	init<T: Equatable>(arrayValues: [T], viewCreator: @escaping (T) -> UIView) {
		self.viewCount = arrayValues.map { (viewCreator($0), 1) }
        super.init(underlyingViews: [], buildingBlocks: [])
		
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func expand() {
		self.viewCount = self.viewCount.map {
			($0.0, ($0.0 as? InternalLazyCollatedView)?.count ?? $0.1)
		}
	}
	
	override var underlyingViews: [UIView] {
		return (0..<count).map { self[$0] }
	}
	
	override var arrangedSubviews: [UIView] {
		return self.underlyingViews
	}
	
	override func asTopLevelView() -> UIView {
		self.underlyingViews.forEach(self.addSubview(_:))
		return self
	}
}
