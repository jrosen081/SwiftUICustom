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
				Text("The count here is: \(count). Inside the object is \(object.value)")
					.navigationTitle("Second Page")
					.onAppear {
						print("Achieved")
					}.padding()
					.font(.systemFont(ofSize: 7))
				Spacer()
				Button(action: {
					self.count += 1
					self.isShowing = true
				}, content: { Text("Nope") }).padding()
				Spacer()
				NavigationLink(destination: ThirdView()) {
					Text("On to the next one")
				}.padding()
			}
			ForEach(currentValues, id: \.int) { value in
				Button(action: {
					(0..<value).forEach { print($0) }
				}, content: {
					Image("arrow")
					.padding()
					.clipShape(Circle())
				})
            }.navigationItems(trailing: Text("Fake"))
		}.popover(isShowing: $isShowing) {
			CheckThis()
		}
	}}

struct CheckThis: View {
    @State var value = 1
    
    var body: OnTapGestureView<Text> {
        Text("Value: \(value)")
            .onTapGesture {
                self.value += 1
            }
    }
}

struct Values {
	let int: Int
}
