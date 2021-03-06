//
//  EnvironmentValues.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

extension NSTextAlignment: Hashable {}
extension UIKeyboardType: Hashable {}

public struct EnvironmentValues: Hashable {
    public func hash(into hasher: inout Hasher) {
        lineLimit?.hash(into: &hasher)
        lineSpacing.hash(into: &hasher)
        minimumScaleFactor.hash(into: &hasher)
        multilineTextAlignment.hash(into: &hasher)
        keyboardType.hash(into: &hasher)
        font?.hash(into: &hasher)
        isLabelsHidden.hash(into: &hasher)
        listStyle._tableViewStyle.hash(into: &hasher)
        foregroundColor?.hash(into: &hasher)
        allowsTightening.hash(into: &hasher)
        textContentType?.hash(into: &hasher)
        currentAnimation?.hash(into: &hasher)
        currentTransition?.hash(into: &hasher)
        pickerStyle._pickerStyle.hash(into: &hasher)
        inList.hash(into: &hasher)
        textFieldStyle._testFieldStyle.hash(into: &hasher)
        colorScheme.hash(into: &hasher)
        keyLookers.hash(into: &hasher)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.lineLimit == rhs.lineLimit
            && lhs.lineSpacing == rhs.lineSpacing
            && lhs.minimumScaleFactor == rhs.minimumScaleFactor
            && lhs.multilineTextAlignment == rhs.multilineTextAlignment
            && lhs.keyboardType == rhs.keyboardType
            && lhs.font == rhs.font
            && lhs.isLabelsHidden == rhs.isLabelsHidden
            && lhs.listStyle._tableViewStyle == rhs.listStyle._tableViewStyle
            && lhs.foregroundColor == rhs.foregroundColor
            && lhs.allowsTightening == rhs.allowsTightening
            && lhs.textContentType == rhs.textContentType
            && lhs.currentTransition == rhs.currentTransition
            && lhs.currentAnimation == rhs.currentAnimation
            && lhs.pickerStyle._pickerStyle == rhs.pickerStyle._pickerStyle
            && lhs.inList == rhs.inList
            && lhs.textFieldStyle._testFieldStyle == rhs.textFieldStyle._testFieldStyle
            && lhs.colorScheme == rhs.colorScheme
            && lhs.keyLookers == rhs.keyLookers
    }
    
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
    
    public var keyboardType: UIKeyboardType = .default

	public var font: UIFont? = nil
    
    public var isLabelsHidden = false
    
    var listStyle: ListStyle = DefaultListStyle()
	
	var foregroundColor: UIColor? = nil
	
	var defaultForegroundColor: UIColor {
		self.colorScheme == .dark ? .white : .black
	}
	
	var allowsTightening: Bool = true
	
	var textContentType: UITextContentType? = nil
	
	var currentTransition: AnyTransition? = nil
	
	var currentAnimation: Animation? = nil
    
    var pickerStyle: PickerStyle = DefaultPickerStyle()
    
    var inList = false
    
    var textFieldStyle: TextFieldStyle = DefaultTextFieldStyle()
    
    var buttonStyle: _PrimitiveButtonStyle {
        get {
            return self[PrimitiveButtonStyleKey.self]
        }
        set {
            self[PrimitiveButtonStyleKey.self] = newValue
        }
    }
	
	public var colorScheme: ColorScheme = .light
	
	func withUpdates(_ updates: (inout EnvironmentValues) -> ()) -> EnvironmentValues {
		var value = EnvironmentValues(self)
		updates(&value)
		return value
	}
	
    // TODO: Rethink this one
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

struct PrimitiveButtonStyleKey: EnvironmentKey {
    static var defaultValue: _PrimitiveButtonStyle {
        return DefaultButtonStyle()
    }
}

struct ListStyleKey: EnvironmentKey {
    static var defaultValue: ListStyle {
        return DefaultListStyle()
    }
}

struct KeyLooker: Hashable {
	var actualValue: Any
	var classValue: Any
	
	init(actualValue: Any, classValue: Any) {
		self.actualValue = actualValue
		self.classValue = classValue
	}
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return true
    }
    
    // TODO: Uhh let's get back to this one again
    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(Self.self).hash(into: &hasher)
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
        self.isLabelsHidden = values.isLabelsHidden
        self.keyboardType = values.keyboardType
        self.listStyle = values.listStyle
        self.pickerStyle = values.pickerStyle
        self.inList = values.inList
        self.colorScheme = values.colorScheme
        self.textFieldStyle = values.textFieldStyle
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
