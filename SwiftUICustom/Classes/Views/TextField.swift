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
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let swiftUITextField = SwiftUITextField(binding: self.binding)
        environment.currentStateNode.buildingBlock = self.label
		let otherView = self.label._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = otherView
        let stackView = SwiftUIStackView(arrangedSubviews: [otherView, swiftUITextField], buildingBlocks: [self.label, UIViewWrapper(view: swiftUITextField)])
		swiftUITextField.textColor = environment.foregroundColor ?? environment.defaultForegroundColor
        swiftUITextField.font = environment.font
        swiftUITextField.keyboardType = environment.keyboardType
        swiftUITextField.textContentType = environment.textContentType
        swiftUITextField.autocorrectionType = environment.disableAutocorrection ?? false ? .no : .default
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
        guard let swiftUITextField = view.subviews[1] as? SwiftUITextField else { return }
        if let text = self.label as? Text {
            environment.textFieldStyle._updateTextField(swiftUITextField, label: text)
        }
        swiftUITextField.textColor = environment.foregroundColor ?? environment.defaultForegroundColor
        swiftUITextField.font = environment.font
        swiftUITextField.keyboardType = environment.keyboardType
        swiftUITextField.textContentType = environment.textContentType
        swiftUITextField.autocorrectionType = environment.disableAutocorrection ?? false ? .no : .default
        swiftUITextField.isSecureTextEntry = self.isSecure
        swiftUITextField.text = binding.wrappedValue
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

public class SwiftUITextField: UITextField, UITextFieldDelegate {
	let binding: Binding<String>
    
    
	
	init(binding: Binding<String>) {
		self.binding = binding
		super.init(frame: .zero)
		self.layoutIfNeeded()
		self.text = binding.wrappedValue
		self.translatesAutoresizingMaskIntoConstraints = false
		self.addTarget(self, action: #selector(self.changedData), for: .editingChanged)
        setContentHuggingPriority(.init(100), for: .horizontal)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	    
    @objc func changedData() {
        self.binding.wrappedValue = self.text!
    }
}
