//
//  ForEach.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/31/20.
//

import Foundation

public struct ForEach<Element, ID: Hashable, Content: View>: View, Expandable {
    
	let elements: [Element]
	let mapper: (Element) -> ID
	let contentMapper: (Element, ID) -> TaggedView<ID, Content>
	
	public init(_ elements: [Element], id: @escaping (Element) -> ID, @ViewBuilder _ contentMapper: @escaping (Element) -> Content) {
		self.elements = elements
		self.mapper = id
		self.contentMapper = {
            contentMapper($0).tag($1)
        }
	}
    
    public init(_ elements: [Element], id: KeyPath<Element, ID>, @ViewBuilder _ contentMapper: @escaping (Element) -> Content) {
        self.elements = elements
        self.mapper = { $0[keyPath: id] }
        self.contentMapper = {
            contentMapper($0).tag($1)
        }
    }

	
	func expanded() -> [_BuildingBlock] {
        return elements.map { contentMapper($0, mapper($0)) }
	}
    
    public var _viewInfo: _ViewInfo {
        return _ViewInfo(isBase: true, baseBlock: self, layoutPriority: .inBetween)
    }
	
	public var body: VStack<TupleView<([_BuildingBlock])>> {
        VStack {
            self.expanded()
        }
	}
}

public extension ForEach where Element : Hashable, ID == Element {
	init(_ elements: [Element], @ViewBuilder _ contentMapper: @escaping (ID) -> Content) {
		self = ForEach(elements, id: {(element: Element) -> Element in element }, contentMapper)
	}
}
