//
//  SwiftUIViewTest.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 9/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct SwiftUIViewTest: View {
    var body: some View {
        VStack {
            Text("Hi")
            Spacer()
            GeometryReader { proxy in
                Text("hi")
            }
            Text("this")
            HStack { Spacer() }
            Text("other")
            GeometryReader { proxy in
                Color.green
                Text("This")
            }
        }
    }
}

@available(iOS 13.0.0, *)
struct SwiftUIViewTest_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIViewTest()
    }
}
