//
//  SwiftUIView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

internal class SwiftUIView: UIControl {
	var onAppear: (() -> ())? = nil
	
	override func didMoveToSuperview() {
		if self.superview != nil {
			self.onAppear?()
		}
	}
	
	override func willExpand(in context: ExpandingContext) -> Bool {
		return self.subviews[0].willExpand(in: context)
	}
}
