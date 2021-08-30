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
    @Binding var exampleModelFromApp: Int
	@Environment(\.colorScheme) var colorScheme
	@State var currentCount = 0
	@ObservedObject var model = ExampleModel()
	@State var textCount = 1
	var values = ["HI", "BYE"]
    @Environment(\.scenePhase) private var scenePhase
	
	var body: some View {
		NavigationView {
			VStack {
                Group {
                    CheckThis()
                    Text("\(Date())")
                    Text("\(exampleModelFromApp)")
                        .onTapGesture {
                            exampleModelFromApp += 1
                        }
                }.onChange(of: currentCount) {
                    print("\($0) is the new value")
                }.onChange(of: scenePhase) { print(String(describing: $0)) }
				HStack {
					Text("Hi")
						.padding(edges: [.trailing])
                        .shadow(width: 5)
                        .opacity(self.model.value > 0 ? 1 : 0)
                        .onDrag {
                            NSItemProvider(item: NSNumber(value: 1), typeIdentifier: "test")
                        }
					NavigationLink(destination: SecondScreen(count: $currentCount)) {
						Text("Bye")
						}.padding().background(.green)
				}.padding()
				Spacer()
                Button {
					self.currentCount += 1
				} content: {
                    Text("The current count is \(currentCount)").padding(edges: [.top], paddingSpace: 10)
				}.frame(width: UIScreen.main.bounds.width - 10, height: 100)
				Spacer()
				ForEach(values) {
                    Text($0).contextMenu {
                        Button(action: {
                            print("again")
                        }, content: {
                            Image(systemImage: "person.fill")
                            Text("Print again")
                        })
                        
                        Button(action: {
                            print("no")
                        }, content: {
                            Image(systemImage: "person")
                            Text("Print no")
                        })

                    }
				}
				Spacer()
				Text("Spaced at the bottom")
					.padding(edges: [.bottom])
                    .onDrop(of: ["test"]) { providers, _ in
                        providers.first?.loadDataRepresentation(forTypeIdentifier: "test") { data, _ in
                            print(String(data: data ?? Data(), encoding: .utf8) as Any)
                        }
                        return true
                    }
                Group {
                    Spacer()
                    if #available(iOS 14, *) {
                        Menu({
                            Menu({
                                Button {
                                    print("uhh")
                                } content: {
                                    Text("Inner")
                                    Image(systemImage: "person.fill")
                                }
                            }, label: {
                                Text("My inner menu")
                            })
                            Button(action: {
                                print("This")
                            }, content: {
                                Text("Show this")
                            })
                        }, label: {
                            Text("Show menu")
                        })
                    }
                }
				HStack {
					Text("The observed value is \(model.value)")
						.onTapGesture {
                            withAnimation {
                                self.model.value.negate()
                            }
                        }
					Spacer()
				}.padding()
					.navigationItems(trailing: Text("Trailing"))
			}.navigationTitle("My name")
				.environmentObject(model)
        }
	}
}
