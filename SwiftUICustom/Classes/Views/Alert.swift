//
//  Alert.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct Alert: Hashable {
	
	let title: String
	let message: String?
	let primaryButton: Alert.Button
	let secondaryButton: Alert.Button?
	
	public init(title: Text, message: Text? = nil, primaryButton: Alert.Button, secondaryButton: Alert.Button) {
		self.title = title.text
		self.message = message?.text
		self.primaryButton = primaryButton
		self.secondaryButton = secondaryButton
	}
	
	public init(title: Text, message: Text?, dismissButton: Alert.Button?) {
		self.title = title.text
		self.message = message?.text
		self.primaryButton = dismissButton ?? Button.default(Text("OK"), action: nil)
		self.secondaryButton = nil
	}
	
	func toController(callback: (() -> ())?) -> UIAlertController {
		let controller = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
		controller.addAction(self.primaryButton.toAlert(callback))
		self.secondaryButton.map { $0.toAlert(callback) }.map(controller.addAction)
		return controller
	}
	
    public struct Button: Hashable {
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.text == rhs.text && lhs.style == rhs.style
        }
        
        public func hash(into hasher: inout Hasher) {
            text.hash(into: &hasher)
            style.hash(into: &hasher)
        }
        
		let text: String
		let onClick: (() -> ())?
		let style: UIAlertAction.Style
		
		func toAlert(_ callback: (() -> ())?) ->  UIAlertAction {
			return UIAlertAction(title: self.text, style: self.style) {_ in
				self.onClick?()
				callback?()
			}
		}
		public static func cancel(_ onClick: (() -> Void)?) -> Alert.Button {
			return Button(text: "Cancel", onClick: onClick, style: .cancel)
		}
		
		public static func cancel(_ text: Text, action: (() -> Void)?) -> Alert.Button {
			return Button(text: text.text, onClick: action, style: .cancel)
		}
		
		public static func `default`(_ text: Text, action: (() -> Void)?) -> Alert.Button {
			return Button(text: text.text, onClick: action, style: .default)
		}
		
		public static func destructive(_ text: Text, action: (() -> Void)?) -> Alert.Button {
			return Button(text: text.text, onClick: action, style: .destructive)
		}
	}
}

public struct AlertView<Content: View>: View {
    
    public func _isEqual(toSameType other: AlertView<Content>, environment: EnvironmentValues) -> Bool {
        let lhs = self
        let rhs = other
        return lhs.alert == rhs.alert && lhs.content._isEqual(to: rhs, environment: environment) && lhs.binding.wrappedValue == rhs.binding.wrappedValue
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        alert.hash(into: &hasher)
        content._hash(into: &hasher, environment: environment)
        binding.wrappedValue.hash(into: &hasher)
    }
    
	let binding: Binding<Bool>
	let alert: Alert
	let content: Content
	
	public var body: Content {
		return self.content
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		if binding.wrappedValue {
			enclosingController.present(self.alert.toController(callback: { self.binding.wrappedValue = false }), animated: true, completion: nil)
		}
		
		return content._toUIView(enclosingController: enclosingController, environment: environment)
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.body._redraw(view: view, controller: controller, environment: environment)
		if binding.wrappedValue {
			controller.present(self.alert.toController(callback: { self.binding.wrappedValue = false }), animated: true, completion: nil)
		}
	}
}

public extension View {
	func alert(_ binding: Binding<Bool>, alertBuilder: () -> Alert) -> AlertView<Self> {
		return AlertView(binding: binding, alert: alertBuilder(), content: self)
	}
}

class UpdateDelegateImpl: UpdateDelegate {
	func updateData(with: Animation?) {
		self.updated()
	}
	
	let updated: () -> ()
	
	init(updated: @escaping () -> ()) {
		self.updated = updated
	}
}
