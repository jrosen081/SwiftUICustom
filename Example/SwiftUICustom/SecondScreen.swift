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
    
    @State var otherCount = 1
    
    @StateObject var stateObject = ExampleModel()
	
	public var body: some View {
		VStack {
			HStack {
                Text("The state object value is: \(stateObject.value)")
                
				Text("The count here is: \(count). Inside the object is \(object.value)")
					.navigationTitle("Second Page")
					.onAppear {
						print("Achieved")
					}.padding()
				Spacer()
				Button(action: {
                    self.stateObject.value -= 1
                    self.otherCount += 1
					self.count += 1
					self.isShowing = true
				}, content: { Text("Nope") }).padding()
				Spacer()
				NavigationLink(destination: ThirdView()) {
					Text("On to the next one")
				}.padding()
			}
//            AsyncImage(url: URL(string: "https://storage.googleapis.com/gd-wagtail-prod-assets/original_images/evolving_google_identity_2x1.jpg"))
			ForEach(currentValues, id: \.int) { value in
				Button(action: {
                    (0..<value.int).forEach { print($0) }
				}, content: {
					Image("arrow")
					.padding()
					.clipShape(Circle())
				})
            }.navigationItems(trailing: Text("Fake"))
            Text("\(otherCount)")
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
