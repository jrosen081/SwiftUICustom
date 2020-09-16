//
//  Group.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/7/20.
//

import Foundation

public struct Group<Content: View>: View {
	let contentBuilder: Content
	
	public init(@ViewBuilder contentBuilder: () -> Content) {
		self.contentBuilder = contentBuilder()
	}
	
	public var body: Content {
		return self.contentBuilder
	}
}
