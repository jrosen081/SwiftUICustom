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
