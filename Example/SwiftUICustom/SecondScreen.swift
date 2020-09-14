//
//  SecondScreen.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 8/29/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUICustom

@available(iOS 13.0.0, *)
public struct SecondScreen: View {
	
	@Binding var count: Int
	
	@EnvironmentObject var object: ExampleModel
	
	@State var currentValues: [Values] = [Values(int: 5), Values(int: 3)]
	
	@State var isShowing: Bool = false
	
	public var body: some View {
		VStack {
			HStack {
				Text("The count here is: \(self.count). Inside the object is \(self.object.value)")
					.navigationTitle("Second Page")
					.onAppear {
						print("Achieved")
					}.padding()
					.font(.systemFont(ofSize: 7))
				Spacer()
				Button(content: { Text("Nope") }) {
					self.count += 1
					self.isShowing = true
				}.padding()
				Spacer()
				NavigationLink(destination: ThirdView()) {
					Text("On to the next one")
				}.padding()
			}
			ForEach(self.currentValues, id: \.int) { value in
				Button(content: {
					Image("arrow")
					.padding()
					.clipShape(Triangle())
				}, onClick: {
					(0..<value).forEach { print($0) }
				})
			}
		}.popover(isShowing: self.$isShowing) {
			Text("Showing")
		}
	}
}

struct Values {
	let int: Int
}
