//
//  ForEach.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/31/20.
//

import Foundation

public struct ForEach<Element, ID: Hashable, Content: View>: View {
    
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
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        var previousNodes: [DOMNode] = []
        if !currentNode.values.isEmpty {
            previousNodes = currentNode.get(valueAtIndex: 0) as! [DOMNode]
        }
        
        let currentBuildingBlocks = expanded()
        let diffs = previousNodes.map(\.buildingBlock).diff(other: currentBuildingBlocks)
        let additions = diffs.additions.map { index in
            return (type(of: currentNode).makeNode(environment: currentNode.environment, viewController: currentNode.viewController, buildingBlock: currentBuildingBlocks[index]), index)
        }
        let moves = diffs.moved.map { old, new in
            return (previousNodes[old], new)
        }
        let all = (additions + moves).sorted(by: { $0.1 < $1.1 }).map(\.0)
        if currentNode.values.isEmpty {
            currentNode.values.append(0)
        }
        currentNode.values[0] = all
        let allSequences = all.map { $0.buildingBlock._makeSequence(currentNode: $0) }
        return _ViewSequence(count: allSequences.map(\.count).reduce(0, +)) { index, node in
            let nodeValues = node.values[0] as! [DOMNode]
            var newIndex = index
            for sequence in allSequences {
                if newIndex < sequence.count {
                    return sequence.viewGetter(newIndex, nodeValues[index])
                } else {
                    newIndex -= sequence.count
                }
            }
            fatalError("Bad index?")
        }
    }
}

public extension ForEach where Element : Hashable, ID == Element {
	init(_ elements: [Element], @ViewBuilder _ contentMapper: @escaping (ID) -> Content) {
		self = ForEach(elements, id: {(element: Element) -> Element in element }, contentMapper)
	}
}
