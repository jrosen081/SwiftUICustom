//
//  ThirdView.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 9/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUICustom

private struct ForEachStruct: View {
    @State private var allOptions = [0, 1, 2]
    
    
    var body: ForEach<Int, Int, OnTapGestureView<Text>> {
        ForEach(allOptions, id: \.self) { _ in
            Text("Add option")
                .onTapGesture {
                    allOptions.append(10)
                }
        }
    }
}

@available(iOS 13.0.0, *)
struct ThirdView: View {
	
	@State var isOn: Bool = true
    @State var forJoe: Bool = true
    @State var secure: String = ""
    @FocusState private var isOnText: Bool

	var body: some View {
		VStack {
			List {
                ForEachStruct()
                HStack {
                    Toggle(isOn: $forJoe) {
                        Text("This one is for Joe and is a really long thing")
                    }
                }.contextMenu {
                    Button(action: {
                        forJoe.toggle()
                    }, content: {
                        Text("Toggle")
                    })
                }
                Section(header: Text("Header").padding().foregroundColor(.systemGreen), footer: Text("Footer")) {
                    ForEach(Array(0..<15)) {_ in
                        Text("My section").padding()
                    }
                }
				Text("My name is Jack").padding()
				Button(action: {print("Hi")}, content: { Text("Test this") }).padding()
				ForEach(Array(0..<15)) {
					Text("The current element is \($0)").padding()
				}.navigationTitle("This is a list")
				NavigationLink(destination: FourthView()) {
					Text("One more?")
				}
				if isOn {
					Text("The switch is on")
				}
                ForEach(Array(0..<15)) {_ in
                    CheckThis()
                }
                Label("My name", systemImage: "person").onTapGesture {
                    self.isOnText.toggle()
                }
            }
            SecureField("The value is \(self.secure)", text: self.$secure)
                .focused($isOnText)
			Toggle(isOn: $isOn) {
				Text(isOn ? "Toggling this will hide the row above" : "Toggling this will show the row above").border(.systemBackground).padding().foregroundColor(.systemYellow)
            }.padding().foregroundColor(.systemGreen)
		}.background(.red)
        .listStyle(InsetGroupedListStyle())
        .refreshable { completion in
            print("Refreshing")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                completion()
            }
        }
	}
}
