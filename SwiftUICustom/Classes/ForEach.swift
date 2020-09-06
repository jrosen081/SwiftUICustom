//
//  ForEach.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/31/20.
//

import Foundation

public struct ForEach<Element, StorageType: Equatable, Content: View>: View {
	let elements: [Element]
	let mapper: (Element) -> StorageType
	let contentMapper: (StorageType) -> Content
	
	public init(_ elements: [Element], id: @escaping (Element) -> StorageType, @ViewBuilder _ contentMapper: @escaping (StorageType) -> Content) {
		self.elements = elements
		self.mapper = id
		self.contentMapper = contentMapper
	}
	
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		return InternalLazyCollatedView(arrayValues: self.elements.map(mapper)) {
			self.contentMapper($0).toUIView(enclosingController: enclosingController)
		}
	}
}

public extension ForEach where Element : Equatable, StorageType == Element {
	init(_ elements: [Element], @ViewBuilder _ contentMapper: @escaping (StorageType) -> Content) {
		self = ForEach(elements, id: {(element: Element) -> Element in element }, contentMapper)
	}
}
