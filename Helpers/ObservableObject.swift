//
//  ObservableObject.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/7/20.
//

import Foundation

public protocol ObservableObject {
}

extension ObservableObject {
	func addListener(_ listener: UpdateDelegate) {
		let mirror = Mirror(reflecting: self)
		mirror.children.map { $0.value }
			.compactMap { $0 as? Redrawable }
			.forEach { $0.addListener(listener) }
	}
	
	func stopRedrawing() {
		let mirror = Mirror(reflecting: self)
		mirror.children.map { $0.value }
			.compactMap { $0 as? Redrawable }
			.forEach { $0.stopRedrawing() }
	}
	
	func startRedrawing() {
		let mirror = Mirror(reflecting: self)
		mirror.children.map { $0.value }
			.compactMap { $0 as? Redrawable }
			.forEach { $0.startRedrawing() }
	}
	
	func performAnimation(animation: Animation) {
		let mirror = Mirror(reflecting: self)
		mirror.children.map { $0.value }
			.compactMap { $0 as? Redrawable }
			.map {(redrawable: Redrawable) -> Redrawable in
				redrawable.startRedrawing()
				return redrawable
			}.first?.performAnimation(animation: animation)
	}
}



@propertyWrapper
public class Published<Value>: State<Value> {
	public override var wrappedValue: Value {
		get {
			return super.wrappedValue
		}
		set {
			super.wrappedValue = newValue
		}
	}
}

@propertyWrapper
public class ObservedObject<Object: ObservableObject>: Redrawable {
	let value: Object
	
	func startRedrawing() {
		self.value.startRedrawing()
	}
	
	func stopRedrawing() {
		self.value.stopRedrawing()
	}
	
	func performAnimation(animation: Animation) {
		self.value.performAnimation(animation: animation)
	}
	
	func addListener(_ listener: UpdateDelegate) {
		self.value.addListener(listener)
	}
	
	public init(wrappedValue: Object) {
		self.value = wrappedValue
	}
	
	public var wrappedValue: Object {
		return value
	}
}
