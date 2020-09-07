//
//  EnvironmentValues.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct EnvironmentValues {
	public var lineLimit: Int? = nil {
		didSet {
			if let limit = lineLimit, limit < 1 {
				self.lineLimit = 1
			}
		}
	}
	
	public var lineSpacing: CGFloat = 10
	
	public var minimumScaleFactor: CGFloat = 0.25
	
	public var multilineTextAlignment: NSTextAlignment = .center

	public var font: UIFont? = nil
	
	var foregroundColor: UIColor? = nil
	
	var defaultForegroundColor: UIColor {
		self.colorScheme == .dark ? .white : .black
	}
	
	var allowsTightening: Bool = true
	
	var textContentType: UITextContentType? = nil
	
	
	public var colorScheme: ColorScheme = .dark
	
	func withUpdates(_ updates: (inout EnvironmentValues) -> ()) -> EnvironmentValues {
		var value = EnvironmentValues(self)
		updates(&value)
		return value
	}
}

extension EnvironmentValues {
	init(_ values: EnvironmentValues) {
		self.lineLimit = values.lineLimit
		self.lineSpacing = values.lineSpacing
		self.minimumScaleFactor = values.minimumScaleFactor
		self.multilineTextAlignment = values.multilineTextAlignment
		self.font = values.font
		self.foregroundColor = values.foregroundColor
		self.allowsTightening = values.allowsTightening
		self.textContentType = values.textContentType
	}
}
