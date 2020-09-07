//
//  UIView+Extension.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/30/20.
//

import Foundation

extension UIView {
	func updateViewHierarchy<Content: View>(other view: UIView, actualView: Content, enclosingController: UIViewController) -> UIView? {
		if self == view {
			return nil
		}
		
		// If it is not an internal type, then it doesn't technically add to the view hierarchy, but it's body property might
		if !(actualView.body is Content) {
			return self.updateViewHierarchy(other: view, actualView: actualView.body, enclosingController: enclosingController)
		}
		
//		if !self.isKind(of: view.classForCoder) || !view.isKind(of: self.classForCoder) {
//			return actualView.toUIView(enclosingController: enclosingController)
//		}
		
		
		 
		
		return nil
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
}
