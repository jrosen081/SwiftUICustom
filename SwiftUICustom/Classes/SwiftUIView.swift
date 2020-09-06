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
	
	override var tintColor: UIColor! {
		didSet {
			self.subviews.forEach {
				$0.tintColor = self.tintColor
				if let label = $0 as? UILabel {
					label.textColor = self.tintColor
				}
			}
		}
	}
	
	static func == (lhs: SwiftUIView, rhs: SwiftUIView) -> Bool {
		return lhs.subviews == rhs.subviews
	}
}
