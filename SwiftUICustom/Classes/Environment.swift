//
//  Environment.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

@propertyWrapper
public class Environment<Value>: EnvironmentNeeded {
	var environment: EnvironmentValues = EnvironmentValues()
	let environmentFunc: (EnvironmentValues) -> Value
	
	public init(_ environmentFunc: @escaping (EnvironmentValues) -> Value) {
		self.environmentFunc = environmentFunc
	}
	
	public var wrappedValue: Value {
		return environmentFunc(environment)
	}
}

protocol EnvironmentNeeded: AnyObject {
	var environment: EnvironmentValues { get set }
}
