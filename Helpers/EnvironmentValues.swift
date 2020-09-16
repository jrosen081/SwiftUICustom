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
	
	var currentTransition: AnyTransition? = nil
	
	var currentAnimation: Animation? = nil
	
	public var colorScheme: ColorScheme = .dark
	
	func withUpdates(_ updates: (inout EnvironmentValues) -> ()) -> EnvironmentValues {
		var value = EnvironmentValues(self)
		updates(&value)
		return value
	}
	
	var keyLookers: [KeyLooker] = []
	
	subscript<K>(key: K.Type) -> K.Value where K : EnvironmentKey {
		get {
			(self.keyLookers.first(where: { $0.classValue is K.Type })?.actualValue as? K.Value) ?? K.defaultValue
		}
		set {
			if var looker = self.keyLookers.first(where: { $0.classValue is K.Type }) {
				looker.actualValue = newValue
			} else {
				self.keyLookers.append(KeyLooker(actualValue: newValue, classValue: K.self))
			}
		}
	}
}

struct EnvironmentObjectGetter<Object>: EnvironmentKey {
	static var defaultValue: Object {
		fatalError("No object was found in the environment of type: \(Object.self)")
	}
}

struct KeyLooker {
	var actualValue: Any
	var classValue: Any
	
	init(actualValue: Any, classValue: Any) {
		self.actualValue = actualValue
		self.classValue = classValue
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
		self.keyLookers = values.keyLookers
		self.currentTransition = values.currentTransition
		self.currentAnimation = values.currentAnimation
	}
	
	init(_ controller: UIViewController) {
		self = EnvironmentValues()
		if #available(iOS 12.0, *) {
			self.colorScheme = controller.traitCollection.userInterfaceStyle == .dark ? .dark : .light
		} else {
			self.colorScheme = .light
		}
	}
}

public protocol EnvironmentKey {
	associatedtype Value
	static var defaultValue: Self.Value { get }
}
