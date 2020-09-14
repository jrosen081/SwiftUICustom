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

	var body: some View {
		VStack {
			List {
				Text("My name is Jack").padding()
				Button(content: { Text("Test this") }, onClick: {}).padding()
				ForEach(Array(0..<15)) {
					Text("The current element is \($0)").padding()
				}.navigationTitle("This is a list")
				NavigationLink(destination: FourthView()) {
					Text("One more?")
				}
				if self.isOn {
					Text("The switch is on")
				}
			}
			Toggle(isOn: self.$isOn) {
				Text(self.isOn ? "Toggling this will hide the row above" : "Toggling this will show the row above").border(.systemBackground).padding().foregroundColor(.systemYellow)
			}.padding().foregroundColor(.systemGreen)
		}.background(.red)
		.foregroundColor(.gray)
		.environment(\.colorScheme, .light)
	}
}
