//
//  TabViewExample.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 10/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUICustom

@available(iOS 13.0.0, *)
struct TabViewExample: View {
    @State var count = 12
    @State var username = "My name"
    @State var password = "no"
    @State var whatOption = false
    var body: some View {
        TabView {
            Text(whatOption ? "Not option 1" : "Option 1")
                .onTapGesture {
                    self.whatOption.toggle()
                }
                .tabBarItem {
                    Text("My option")
                }
            Text("Next Option with value: \(count)").onTapGesture {
                self.count *= -1
            }.tabBarItem {
                Text("Try this?")
                Image(systemImage: "pencil")
            }
            Form {
                Section(header: Text("First Section")) {
                    Text("Try this").padding()
                    Picker("My favorite number is: ", selection: $count) {
                        Text("12").padding().tag(12)
                        Text("55").padding().tag(55)
                        Text("44").padding().tag(44)
                        Image(systemImage: "trash").fixedSize(width: 30, height: 50).tag(100)
                    }
                }
                Section(header: Text("Username and Password")) {
                    TextField("Username", text: self.$username)
                    SecureField("Password", text: self.$password)
                        .textContentType(.password)
                }
                Button(action: {
                    print("Sending count: \(count)")
                }, content: {
                    Text("Send the count to someone")
                })
            }.tabBarItem {
                Text("Form")
                Image(systemImage: "rectangle")
            }
        }.navigationTitle("Tab View Let's GOOOO")
    }
}
