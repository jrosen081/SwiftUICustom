//
//  TextField.swift
//  Pods-SwiftUICustom_Example
//
//  Created by Jack Rosen on 9/9/20.
//

import Foundation

public struct TextField<Label: View>: View {
	let binding: Binding<String>
	let label: Label
    let isSecure: Bool
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let swiftUITextField = SwiftUITextField(binding: self.binding)
		let otherView = self.label.padding().__toUIView(enclosingController: enclosingController, environment: environment)
		let stackView = SwiftUIStackView(arrangedSubviews: [otherView, swiftUITextField], context: .horizontal)
		swiftUITextField.textColor = environment.foregroundColor ?? environment.defaultForegroundColor
        swiftUITextField.font = environment.font
        swiftUITextField.keyboardType = environment.keyboardType
        swiftUITextField.textContentType = environment.textContentType
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
        otherView.isHidden = environment.isLabelsHidden
        if let text = self.label as? Text {
            environment.textFieldStyle._updateTextField(swiftUITextField, label: text)
        }
        swiftUITextField.isSecureTextEntry = self.isSecure
		return stackView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.label.padding()._redraw(view: view.subviews[0], controller: controller, environment: environment)
        view.subviews[0].isHidden = environment.isLabelsHidden
        
	}
}

public extension TextField {
    init<S>(_ title: S, text: Binding<String>) where S : StringProtocol, Label == Text {
        self.label = Text(String(title))
        self.binding = text
        self.isSecure = false
    }
    
    init<S, T>(_ title: S, value: Binding<T>, formatter: Formatter) where S : StringProtocol, Label == Text {
        self.label = Text(String(title))
        self.binding = Binding(get: {
            return formatter.string(for: value.wrappedValue) ?? ""
        }, set: { newValue in
            var object: AnyObject? = nil
            var error: NSString?
            formatter.getObjectValue(&object, for: newValue, errorDescription: &error)
            if let object = object as? T {
                value.wrappedValue = object
            }
        })
        self.isSecure = false
    }
}

class SwiftUITextField: UITextField, UITextFieldDelegate, UpdateDelegate {
	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIView.layoutFittingExpandedSize.width, height: super.intrinsicContentSize.height)
	}
	
	override func willExpand(in context: ExpandingContext) -> Bool {
		return context == .horizontal
	}
	
	let binding: Binding<String>
	
	init(binding: Binding<String>) {
		self.binding = binding
		super.init(frame: .zero)
		self.layoutIfNeeded()
		self.text = binding.wrappedValue
		self.translatesAutoresizingMaskIntoConstraints = false
		self.addTarget(self, action: #selector(self.changedData), for: .editingChanged)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateData(with animation: Animation?) {
		DispatchQueue.main.async {
			self.text = self.binding.wrappedValue
		}
	}
	
	@objc func changedData() {
		guard let text = self.text else { return }
		self.binding.wrappedValue = text
	}
}
