//
//  SecureTextField.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/1/20.
//

import Foundation

public struct SecureField<Label>: View where Label : View {
    let string: Label
    let binding: Binding<String>
    public init<S: StringProtocol>(_ string: S, text: Binding<String>) where Label == Text {
        self.string = Text(String(string))
        self.binding = text
    }
    
    public var body: TextField<Label> {
        TextField(binding: self.binding, label: self.string, isSecure: true)
    }
}
