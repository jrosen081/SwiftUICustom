//
//  EnvironmentValues.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

extension NSTextAlignment: Hashable {}
extension UIKeyboardType: Hashable {}

public struct EnvironmentValues {    
	public var lineLimit: Int? = nil {
		didSet {
			if let limit = lineLimit, limit < 1 {
				self.lineLimit = 1
			}
		}
	}
    
    private(set) public var openUrl = OpenURLAction()
	
	public var lineSpacing: CGFloat = 10
	
    public var minimumScaleFactor: CGFloat = 0.25
	
	public var multilineTextAlignment: NSTextAlignment = .center
    
    public var keyboardType: UIKeyboardType = .default
    
    public var truncationType = NSLineBreakMode.byTruncatingTail
    
    public var disableAutocorrection: Bool? = nil
    
    public var textCase: Text.Case?
    
    public var calendar: Calendar = Calendar.autoupdatingCurrent

	public var font: UIFont? = nil
    
    public var isLabelsHidden = false
    
    public var locale: Locale = Locale.current
    
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
    
    public private(set) var presentationMode: PresentationMode = PresentationMode(isPresented: false, dismiss: {})
    
    public var timeZone: TimeZone = TimeZone.current
    
    public var horizontalSizeClass: UIUserInterfaceSizeClass? = nil
    
    public var verticallSizeClass: UIUserInterfaceSizeClass? = nil
    
    private var _currentStateNode: DOMNode? = nil
    
    var currentStateNode: DOMNode {
        get {
            _currentStateNode ?? {
                fatalError()
            }()
        }
        set {
            _currentStateNode = newValue
            _currentStateNode?.environment = self
        }
    }
    
    var labelStyleFunc: (LabelStyleConfiguration) -> _BuildingBlock = DefaultLabelStyle().asFunc
    
    var setColorScheme = false
    
    public var refreshAction: RefreshAction?
    
    var boxStyle: BoxStyle = BoxStyle(style: DefaultGroupBoxStyle())
	
    public var colorScheme: ColorScheme = .light {
        didSet {
            setColorScheme = true
        }
    }
	
	func withUpdates(_ updates: (inout EnvironmentValues) -> ()) -> EnvironmentValues {
		var value = self
		updates(&value)
		return value
	}
	
    var keyLookers: [ObjectIdentifier: Any] = [:]
    
    subscript<K>(identifier: ObjectIdentifier, defaultValue: K) -> K {
        return self.keyLookers[identifier] as? K ?? defaultValue
    }
	
	subscript<K>(key: K.Type) -> K.Value where K : EnvironmentKey {
		get {
            self.keyLookers[ObjectIdentifier(key)] as? K.Value ?? key.defaultValue
		}
		set {
            self.keyLookers[ObjectIdentifier(key)] = newValue
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

extension EnvironmentValues {
	init(_ controller: UIViewController) {
		self = EnvironmentValues()
        self.presentationMode = PresentationMode(isPresented: controller.presentingViewController != nil) { [weak controller] in
            controller?.dismiss(animated: true, completion: nil)
        }
        self.horizontalSizeClass = controller.traitCollection.horizontalSizeClass
        self.verticallSizeClass = controller.traitCollection.verticalSizeClass
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
