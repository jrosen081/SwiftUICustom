//
//  SampleView.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 8/28/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUICustom

@available(iOS 13,  *)
struct SampleView: View {
	@Environment(\.colorScheme) var colorScheme
	@State var currentCount = 0
	var values = ["HI", "BYE"]
	
	var body: some View {
		NavigationView {
			VStack {
				HStack {
					Text("Hi")
						.padding(corners: [.trailing])
					NavigationLink(destination: SecondScreen(count: self.$currentCount)) {
						Text("Bye")
						}.padding().background(.systemGreen)
				}.padding()
					.foregroundColor(self.colorScheme == .dark ? .yellow : .green)
				Spacer()
				 Button(content: {
					Text("The current count is \(self.currentCount)")
						.padding(corners: [.top], paddingSpace: 10)
				}) {
					self.currentCount += 1
				}.fixedSize(width: UIScreen.main.bounds.width - 10, height: 100)
				Spacer()
				ForEach(self.values) {
					Text($0)
				}
				Spacer()
				Text("Spaced at the bottom")
					.padding(corners: [.bottom])
				Spacer()
			}.navigationTitle("My name")
		}
	}
}
