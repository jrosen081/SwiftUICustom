//
//  TextFieldStyle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/9/20.
//

import Foundation
import UIKit

public protocol TextFieldStyle {
    func _updateTextField(_ textField: UITextField, label: Text)
}

public struct PlainTextFieldStyle: TextFieldStyle {
    public func _updateTextField(_ textField: UITextField, label: Text){
        // Do nothing
    }
}

public typealias DefaultTextFieldStyle = PlainTextFieldStyle

public struct RoundedBorderTextFieldStyle: TextFieldStyle {
    public func _updateTextField(_ textField: UITextField, label: Text) {
        textField.borderStyle = .roundedRect
    }
}

struct FormTextFieldStyle: TextFieldStyle {
    func _updateTextField(_ textField: UITextField, label: Text) {
        textField.placeholder = label.text
    }
}



