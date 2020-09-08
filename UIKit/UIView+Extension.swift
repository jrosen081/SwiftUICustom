//
//  UIView+Extension.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/30/20.
//

import Foundation

extension UIView {
	func setupFullConstraints(_ view1: UIView, _ view2: UIView) {
		NSLayoutConstraint.activate([
			view1.bottomAnchor.constraint(equalTo: view2.bottomAnchor),
			view1.leadingAnchor.constraint(equalTo: view2.leadingAnchor),
			view1.trailingAnchor.constraint(equalTo: view2.trailingAnchor),
			view1.topAnchor.constraint(equalTo: view2.topAnchor)
		])
	}
	
	@objc func asTopLevelView() -> UIView {
		return self
	}
	
	@discardableResult
	@objc func insideList() -> (() -> ())? {
		let values = self.subviews.map { $0.insideList() }
		self.isUserInteractionEnabled = false
		return values.first(where: { $0 != nil}) ?? nil
	}
	
	@objc var willExpand: Bool {
		return false
	}
}
