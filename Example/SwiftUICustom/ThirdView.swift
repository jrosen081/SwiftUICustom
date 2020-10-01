//
//  ThirdView.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 9/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUICustom

@available(iOS 13.0.0, *)
struct ThirdView: View {
	
	@State var isOn: Bool = true
    @State var secure: String = ""

	var body: some View {
		VStack {
			List {
                Section(header: Text("Header").padding().foregroundColor(.systemGreen), footer: Text("Footer")) {
                    ForEach(Array(0..<15)) {_ in
                        Text("My section").padding()
                    }
                }
				Text("My name is Jack").padding()
				Button(action: {}, content: { Text("Test this") }).padding()
				ForEach(Array(0..<15)) {
					Text("The current element is \($0)").padding()
				}.navigationTitle("This is a list")
				NavigationLink(destination: FourthView()) {
					Text("One more?")
				}
				if isOn {
					Text("The switch is on")
				}
            }
            SecureField("The value is \(self.secure)", text: self.$secure)
			Toggle(isOn: $isOn) {
				Text(isOn ? "Toggling this will hide the row above" : "Toggling this will show the row above").border(.systemBackground).padding().foregroundColor(.systemYellow)
			}.padding().foregroundColor(.systemGreen)
		}.background(.red)
        .listStyle(InsetGroupedListStyle())
	}
}
