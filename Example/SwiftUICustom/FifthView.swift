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
	@State var isShowingOverlay: Bool = false
	
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
			Button(action: {
				self.value.value += 1
			}, content: {
				Text("The count inside value is \(self.value.value). Click to update")
			}).modifier(GreenView())
		}.padding(paddingSpace: 10).border(.black, lineWidth: 10).padding()
			.transition(.opacity)
			.animation(.linear(duration: 2))
			.navigationItems(trailing: Button(action: {
				withAnimation { self.isShowingOverlay.toggle() }
			}, content: {
			Text(self.isShowingOverlay ? "Hide" : "Show")
		}))
	}
}

@available(iOS 13, *)
struct SixthView: View {
	@State var number: Int = 0
	@State var textCount: Int = 1
	@State var value: Double = 1
	@State var stepperState: Float = 15
    @State var pickerValue: String = "Mine"
	
	var body: some View {
		VStack {
			if self.number <= 5 {
				Button(action: {
                    self.pickerValue = "Mine"
					withAnimation {
						self.number += 1
					}
				}, content: {
					Text("The number is \(number)")
						.transformEffect(number <= 1 ? .identity : .init(translationX: 10, y: 0))
				})
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1))
                    .animation(.easeIn(duration: 1))
			} else {
				Text("This is a big number")
				.padding()
					.foregroundColor(.systemTeal)
			}
			Group {
				if number != 2 {
					Text("The number doesn't equal 2").rotationEffect(.degrees(90))
				} else {
					Text("Scaled").transformEffect(CGAffineTransform(translationX: 20, y: 0))
				}
			}.transition(.slide)
			
			TextField("The count is: ", value: self.$textCount, formatter: {
				let numberFormatter = NumberFormatter()
				return numberFormatter
            }()).keyboardType(.numberPad)
			Text("The parsed value is \(self.textCount)").rotationEffect(self.number == 2 ? .degrees(5) : .degrees(0)).animation(Animation.linear(duration: 10))
			Slider(value: $value, in: (1...15), step: 2) {
				Text("Value: \(value)")
			}.padding()
			Stepper(value: $stepperState, in: (15...30), step: 3) {
				Button(action: {
					self.stepperState = 15
				}, content: {
					Text("Click this to reset. The current # is \(stepperState)")
				})
			}
            Picker("The letters are \(self.pickerValue)", selection: $pickerValue) {
                ForEach(["Yours", "Mine", "Other"]) {
                    Text($0)
                }
                Image("arrow").tag("Eight")
            }
            
			NavigationLink(destination: TopView(), content: {
				Text("On to the Next")
			})
		}.transition(.opacity)
	}
}

@available(iOS 13.0.0, *)
struct TopView: View {
	@State var isShowing: Bool = false
    @State var currentDate = Date()
	
	var body: some View {
		ZStack {
            VStack {
                Text("Behind")
                DatePicker("The date is \(currentDate)", selection: $currentDate)
                    .labelsHidden()
            }
			if isShowing {
				List {
					Text("Showing!").padding()
				}
			}
		}
		.transition(.move(edge: .trailing))
		.animation(.easeIn)
		.navigationItems(trailing: Button(action: {
			self.isShowing.toggle()
		}, content: {
			Text(isShowing ? "Hide" : "Show")
		}))
	}
}
