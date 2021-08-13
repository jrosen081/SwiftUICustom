//
//  SwiftUIViewTest.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 9/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct StateHoldingView: View {
    @State private var value = 0
    
    var body: some View {
        Text("\(value)").onTapGesture {
            value += 1
        }.font(.title)
    }
}

@available(iOS 13.0.0, *)
struct SwiftUIViewTest: View {
    @State private var values = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    var body: some View {
        VStack {
            ForEach(values, id: \.self) { _ in
                StateHoldingView()
            }
            Button(action: {
                self.values.shuffle()
            }) {
                Text("Shuffle")
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
