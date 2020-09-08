//
//  FourthView.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 9/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUICustom

@available(iOS 13.0.0, *)
struct FourthView: View {
	@State var showingAlert: Bool = false
	var body: some View {
		VStack {
			Button(content: { Text("HI") }) {
				self.showingAlert = true
			}.padding()
			NavigationLink(destination: FifthView()) {
				Text("Ready for the ZStack?")
			}
			ScrollView {
				VStack {
					ForEach(Array(0..<15)) { _ in
						HStack {
							ForEach(Array(0..<15)) {
								Text("The actual number is \($0)").padding()
							}
						}
					}
				}
			}.navigationTitle("Horizontal And Vertical Scroll View")
			.padding()
			.foregroundColor(.link)
		}.alert(self.$showingAlert) {
			Alert(title: Text("Button"), primaryButton: .default(Text("Hi"), action: nil), secondaryButton: .default(Text("Bye"), action: nil))
		}
	}
}
