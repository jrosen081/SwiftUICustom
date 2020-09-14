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
	var drawing: Bool = true
	
	func addListener(_ listener: UpdateDelegate) {
		if !listeners.contains(where: { $0 === listener }) {
			self.listeners.append(WeakHolder(object: listener))
		}
	}
	
	func performAnimation(animation: Animation) {
		self.drawing = true
		self.listeners.forEach { $0.object?.updateData(with: animation) }
	}
	
	func startRedrawing() {
		self.drawing = true
	}
	
	func stopRedrawing() {
		self.drawing = false
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
			guard self.drawing else { return }
			self.listeners.forEach { $0.object?.updateData(with: nil) }
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
	func updateData(with animation: Animation?)
}
