//
//  Binding.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

@propertyWrapper
public class Binding<T>: Redrawable {
	var listeners: [WeakHolder] = []
	
	func addListener(_ listener: UpdateDelegate) {
		if !listeners.contains(where: { $0 === listener }) {
			self.listeners.append(WeakHolder(object: listener))
		}
		
	}
	
	var get: () -> T
	var set: (T) -> ()
	
	public init(get: @escaping () -> T, set: @escaping (T) -> ()) {
		self.get = get
		self.set = set
	}
	
	public var wrappedValue: T {
		get {
			self.get()
		}
		set {
			self.set(newValue)
			self.listeners.forEach { $0.object?.updateData() }
		}
	}
	
	public var projectedValue: Binding<T> {
		return self
	}
	
	func reset() {
		// Do nothing
	}
}

class WeakHolder {
	weak var object: UpdateDelegate?
	
	init(object: UpdateDelegate) {
		self.object = object
	}
}

protocol UpdateDelegate: AnyObject {
	func updateData()
}
