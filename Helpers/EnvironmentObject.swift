//
//  EnvironmentObject.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/7/20.
//

import Foundation

@propertyWrapper
public class EnvironmentObject<Value: ObservableObject>: Environment<Value>, Redrawable {
	func addListener(_ listener: UpdateDelegate) {
		self.wrappedValue.addListener(listener)
	}
	
	func startRedrawing() {
		self.wrappedValue.startRedrawing()
	}
	
	func stopRedrawing() {
		self.wrappedValue.stopRedrawing()
	}
	
	func performAnimation(animation: Animation) {
		self.wrappedValue.performAnimation(animation: animation)
	}
	
	public init() {
		super.init({
			return $0[EnvironmentObjectGetter<Value>.self]
		})
	}
	
	public override var wrappedValue: Value {
		return super.wrappedValue
	}
}
