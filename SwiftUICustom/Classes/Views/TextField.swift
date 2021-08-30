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
    @Environment(\.isLabelsHidden) var labelIsHidden
    
	public var body: HStack<TupleView<(ConditionalContent<TupleView<(Label, Spacer)>, EmptyView>, TextFieldRepresentable)>> {
        HStack {
            if !labelIsHidden {
                label
                Spacer()
            }
            TextFieldRepresentable(text: binding, isSecure: isSecure)
        }
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

public struct TextFieldRepresentable: UIViewRepresentable {
    public typealias UIViewType = SwiftUITextField
    
    @Binding var text: String
    let isSecure: Bool
    
    public func makeUIView(context: Context) -> SwiftUITextField {
        let field = SwiftUITextField(binding: $text)
        field.isSecureTextEntry = isSecure
        updateFocus(context: context, textField: field)
        return field
    }
    
    public func updateUIView(_ view: SwiftUITextField, context: Context) {
        view.binding = $text
        view.text = text
        updateFocus(context: context, textField: view)
        view.isSecureTextEntry = isSecure
    }
    
    private func updateFocus(context: Context, textField: SwiftUITextField) {
        if context.environment.isForcedFocus, !textField.isFirstResponder {
            textField.becomeFirstResponder()
        } else if !context.environment.isForcedFocus, textField.isFirstResponder {
            textField.endEditing(true)
        }
        textField.onFirstResponderChange = context.environment.onFocusChange
    }
}

public class SwiftUITextField: UITextField, UITextFieldDelegate {
	var binding: Binding<String>
    var onFirstResponderChange: (Bool) -> Void = {_ in }
    
	
	init(binding: Binding<String>) {
		self.binding = binding
		super.init(frame: .zero)
		self.layoutIfNeeded()
		self.text = binding.wrappedValue
		self.translatesAutoresizingMaskIntoConstraints = false
		self.addTarget(self, action: #selector(self.changedData), for: .editingChanged)
        self.delegate = self
        setContentHuggingPriority(.init(100), for: .horizontal)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	    
    @objc func changedData() {
        self.binding.wrappedValue = self.text!
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        onFirstResponderChange(false)
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        onFirstResponderChange(true)
    }
}
