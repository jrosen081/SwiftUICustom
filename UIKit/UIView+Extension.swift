//
//  UIView+Extension.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/30/20.
//

import Foundation

extension UIView {
	func setupFullConstraints(_ view1: UIView, _ view2: UIView, usingGreaterThan: Bool = false) {
		if usingGreaterThan {
			NSLayoutConstraint.activate([
				view1.bottomAnchor.constraint(greaterThanOrEqualTo: view2.bottomAnchor),
				view1.leadingAnchor.constraint(lessThanOrEqualTo: view2.leadingAnchor),
				view1.trailingAnchor.constraint(greaterThanOrEqualTo: view2.trailingAnchor),
				view1.topAnchor.constraint(lessThanOrEqualTo: view2.topAnchor)
			])
		} else {
			NSLayoutConstraint.activate([
				view1.bottomAnchor.constraint(equalTo: view2.bottomAnchor),
				view1.leadingAnchor.constraint(equalTo: view2.leadingAnchor),
				view1.trailingAnchor.constraint(equalTo: view2.trailingAnchor),
				view1.topAnchor.constraint(equalTo: view2.topAnchor)
			])
		}
	}
	
	@objc func asTopLevelView() -> UIView {
		return self
	}
	
	@discardableResult
	@objc func insideList(width: CGFloat) -> (() -> ())? {
		let values = self.subviews.map { $0.insideList(width: width) }
		return values.first(where: { $0 != nil}) ?? nil
	}
	
	@objc func willExpand(in context: ExpandingContext) -> Bool {
		return false
	}
}
