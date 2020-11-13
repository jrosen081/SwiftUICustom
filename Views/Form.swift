//
//  Form.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/8/20.
//

import Foundation

public struct Form<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder builder: () -> Content) {
        self.content = builder()
    }
    
    public var body: EnvironmentUpdatingView<
        EnvironmentUpdatingView<
            EnvironmentUpdatingView<
                EnvironmentUpdatingView<
                    EnvironmentUpdatingView<
                        EnvironmentUpdatingView<
                            List<Content>>>>>>> {
        List {
            content
        }
        .buttonStyle(FormButtonStyle())
        .listStyle(GroupedListStyle())
        .pickerStyle(FormPickerStyle())
        .foregroundColor(nil)
        .labelsHidden()
        .textFieldStyle(FormTextFieldStyle())
    }
}
