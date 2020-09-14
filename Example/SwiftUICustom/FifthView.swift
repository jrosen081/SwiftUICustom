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
						Circle().fill().foregroundColor(.systemGray).padding()
					}
				}
				Text("Bottom Trailing")
			}
			Button(content: {
				Text("The count inside value is \(self.value.value). Click to update")
			}, onClick: {
				self.value.value += 1
				}).modifier(GreenView())
		}.padding(paddingSpace: 10).border(.black, lineWidth: 10).padding()
	}
}

@available(iOS 13, *)
struct SixthView: View {
	@State var number: Int = 0
	@State var textCount: Int = 1
	@State var value: Double = 1
	@State var stepperState: Float = 15
	
	var body: some View {
		VStack {
			if self.number <= 5 {
				Button(content: {
					Text("The number is \(self.number)")
						.transformEffect(self.number <= 1 ? .identity : .init(translationX: 10, y: 0))
				}, onClick: {
					self.withAnimation {
						self.number += 1
					}
				}).animation(.easeIn(duration: 1))
			} else {
				Text("This is a big number")
				.padding()
					.foregroundColor(.systemTeal)
			}
		
			if self.number != 2 {
				Text("The number doesn't equal 2").rotationEffect(.degrees(90))
			} else {
				Text("Scaled").transformEffect(CGAffineTransform(translationX: 20, y: 0))
			}
			
			TextField("The count is: ", value: self.$textCount, formatter: {
				let numberFormatter = NumberFormatter()
				return numberFormatter
			}())
			Text("The parsed value is \(self.textCount)").rotationEffect(self.number == 2 ? .degrees(5) : .degrees(0))
			Slider(value: self.$value, in: (1...15), step: 2) {
				Text("Value: \(self.value)")
			}.padding()
			Stepper(value: self.$stepperState, in: (15...30), step: 3) {
				Button(content: {
					Text("Click this to reset. The current # is \(self.stepperState)")
				}, onClick: {
					self.stepperState = 15
				})
			}
		}
	}
}
