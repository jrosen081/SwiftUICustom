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
			Text("Top Leading")
		}.padding(paddingSpace: 10).border(.black, lineWidth: 10).padding()
	}
}

@available(iOS 13, *)
struct SixthView: View {
	@State var number: Int = 0
	
	var body: some View {
		Button(content: {
			Text("The number is \(self.number)")
		}, onClick: {
			self.number += 1
		})
	}
}
