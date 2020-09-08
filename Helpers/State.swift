//
//  State.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

@propertyWrapper
public class State<T>: Binding<T> {
	var underlyingValue: T
	
	var startingValue: T
	
	public init(wrappedValue: T) {
		self.underlyingValue = wrappedValue
		self.startingValue = wrappedValue
		super.init(get: { wrappedValue }, set: {_ in })
		self.get = { self.underlyingValue }
		self.set = { self.underlyingValue = $0 }
	}
	
	public override var wrappedValue: T {
		get {
			super.wrappedValue
		}
		set {
			super.wrappedValue = newValue
		}
	}
	
	public override var projectedValue: Binding<T> {
		return self
	}
}
