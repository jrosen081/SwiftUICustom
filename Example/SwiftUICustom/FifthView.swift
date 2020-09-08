//
//  FifthView.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 9/5/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUICustom

@available(iOS 13.0.0, *)
struct FifthView: View {
	
	@EnvironmentObject var value: ExampleModel
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			ZStack(alignment: .bottomTrailing) {
				NavigationLink(destination: SixthView()) {
					ZStack {
						Circle()
						.stroke(lineWidth: 5)
						.padding()
						Circle().fill()
					}
				}
				Text("Bottom Trailing")
			}
			Button(content: {
				Text("The count inside value is \(self.value.value). Click to update")
			}, onClick: {
				self.value.value += 1
			})
		}.padding(paddingSpace: 10).border(.black, lineWidth: 10).padding()
	}
}

@available(iOS 13, *)
struct SixthView: View {
	@State var number: Int = 0
	
	var body: some View {
		VStack {
			if self.number <= 5 {
				Button(content: {
					Text("The number is \(self.number)")
				}, onClick: {
					self.number += 1
				})
			} else {
				Text("This is a big number")
				.padding()
					.foregroundColor(.systemTeal)
			}
			
			if self.number != 2 {
				Text("The number doesn't equal 2")
			}
		}
	}
}
