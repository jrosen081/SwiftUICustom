//
//  ForEach.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/31/20.
//

import Foundation

public struct ForEach<Element, StorageType: Equatable, Content: View>: View, Expandable {
	
	let elements: [Element]
	let mapper: (Element) -> StorageType
	let contentMapper: (StorageType) -> Content
	
	public init(_ elements: [Element], id: @escaping (Element) -> StorageType, @ViewBuilder _ contentMapper: @escaping (StorageType) -> Content) {
		self.elements = elements
		self.mapper = id
		self.contentMapper = contentMapper
	}
	
	func expanded() -> [BuildingBlock] {
		return elements.map(mapper).map(contentMapper)
	}
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		return InternalLazyCollatedView(arrayValues: self.elements.map(mapper)) {
			self.contentMapper($0).toUIView(enclosingController: enclosingController, environment: environment)
		}
	}
	
	public func redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let collated = view as? InternalCollatedView else { return }
		zip(elements, collated.underlyingViews).forEach { element, uiview in
			contentMapper(mapper(element)).redraw(view: uiview, controller: controller, environment: environment)
			
		}
	}
}

public extension ForEach where Element : Equatable, StorageType == Element {
	init(_ elements: [Element], @ViewBuilder _ contentMapper: @escaping (StorageType) -> Content) {
		self = ForEach(elements, id: {(element: Element) -> Element in element }, contentMapper)
	}
}
