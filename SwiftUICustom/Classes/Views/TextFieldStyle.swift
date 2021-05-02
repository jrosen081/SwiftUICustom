//
//  TextFieldStyle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/9/20.
//

import Foundation
import UIKit

public enum _TestFieldStyleEnum: Hashable {
    case plain, roundedBorder, form
}

public protocol TextFieldStyle {
    var _testFieldStyle: _TestFieldStyleEnum { get }
    func _updateTextField(_ textField: UITextField, label: Text)
}

public struct PlainTextFieldStyle: TextFieldStyle {
    public var _testFieldStyle: _TestFieldStyleEnum = .plain
    public func _updateTextField(_ textField: UITextField, label: Text){
        // Do nothing
    }
}

public typealias DefaultTextFieldStyle = PlainTextFieldStyle

public struct RoundedBorderTextFieldStyle: TextFieldStyle {
    public var _testFieldStyle: _TestFieldStyleEnum = .roundedBorder
    public func _updateTextField(_ textField: UITextField, label: Text) {
        textField.borderStyle = .roundedRect
    }
}

struct FormTextFieldStyle: TextFieldStyle {
    var _testFieldStyle: _TestFieldStyleEnum = .form
    func _updateTextField(_ textField: UITextField, label: Text) {
        textField.placeholder = label.text
    }
}



