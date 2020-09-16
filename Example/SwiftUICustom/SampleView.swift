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
	@ObservedObject var model = ExampleModel()
	@State var textCount = 1
	var values = ["HI", "BYE"]
	
	var body: some View {
		NavigationView {
			VStack {
				HStack {
					Text("Hi")
						.padding(corners: [.trailing])
					NavigationLink(destination: SecondScreen(count: $currentCount)) {
						Text("Bye")
						}.padding().background(.systemGreen)
				}.padding()
					.foregroundColor(colorScheme == .dark ? .yellow : .green)
				Spacer()
				Button(action: {
					self.currentCount += 1
				}, content: {
					Text("The current count is \(currentCount)")
						.padding(corners: [.top], paddingSpace: 10)
				}) .fixedSize(width: UIScreen.main.bounds.width - 10, height: 100)
				Spacer()
				ForEach(values) {
					Text($0)
				}
				Spacer()
				Text("Spaced at the bottom")
					.padding(corners: [.bottom])
				Spacer()
				HStack {
					Text("The observed value is \(model.value)")
					Spacer()
				}.padding()
					.navigationItems(trailing: Text("Trailing"))
			}.navigationTitle("My name")
				.environmentObject(model)
				.environment(\.colorScheme, .dark)
		}
	}
}
