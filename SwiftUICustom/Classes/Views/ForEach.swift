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
	let contentMapper: (Element, ID, DOMNode) -> TaggedView<ID, Content>
    @Environment(\.currentStateNode) var currentStateNode
	
	public init(_ elements: [Element], id: @escaping (Element) -> ID, @ViewBuilder _ contentMapper: @escaping (Element) -> Content) {
		self.elements = elements
		self.mapper = id
		self.contentMapper = { element, id, _ in
            contentMapper(element).tag(id)
        }
	}
    
    public init(_ elements: [Element], id: KeyPath<Element, ID>, @ViewBuilder _ contentMapper: @escaping (Element) -> Content) {
        self.elements = elements
        self.mapper = { $0[keyPath: id] }
        self.contentMapper = { element, id, _ in
            contentMapper(element).tag(id)
        }
    }
    
    init(_ elements: [Element], id: @escaping (Element) -> ID, @ViewBuilder _ contentMapper: @escaping (Element, DOMNode) -> Content) {
        self.elements = elements
        self.mapper = id
        self.contentMapper = { element, id, node in
            contentMapper(element, node).tag(id)
        }
    }

	
    func expanded(node: DOMNode) -> [_BuildingBlock] {
        return elements.map { contentMapper($0, mapper($0), node) }
	}
    
    public var _viewInfo: _ViewInfo {
        return _ViewInfo(isBase: true, baseBlock: self, layoutPriority: .inBetween)
    }
	
	public var body: VStack<TupleView<([_BuildingBlock])>> {
        VStack {
            expanded(node: currentStateNode)
        }
	}
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        assert(Thread.isMainThread)
        var previousNodes: [DOMNode] = []
        if !currentNode.values.isEmpty {
            previousNodes = currentNode.get(valueAtIndex: 0) as! [DOMNode]
        }
        
        let currentBuildingBlocks = expanded(node: currentNode)
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
        let allSequences = all.map { node -> _ViewSequence in
            node.environment = node.environment.withUpdates { $0.currentStateNode = node }
            return node.buildingBlock._makeSequence(currentNode: node)
        }
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
    
    
    private func printAndReturn<T>(_ t: T) -> T {
        print(t)
        return t
    }
    
    public func onDelete(perform: ((IndexSet) -> Void)?) -> ForEach<(Int, Element), ID, SwipeActionsView<TaggedView<ID, Content>, Button<Text>>> {
        ForEach<(Int, Element), ID, SwipeActionsView<TaggedView<ID, Content>, Button<Text>>>(Array(self.elements.enumerated()), id: { (val: (Int, Element)) in
            return self.mapper(val.1)
        }) { (value: (Int, Element), node: DOMNode) in
            let (offset, element) = printAndReturn(value)
            contentMapper(element, self.mapper(element), node).swipeActions {
                Button(role: .destructive, action: {
                    print(value)
                    perform?([offset])
                }, content: {
                    Text("Delete")
                })
            }
        }
    }
    
    public func onMove(perform action: Optional<(IndexSet, Int) -> Void>) -> ForEach<(Int, Element), ID, CellDragDropView<TaggedView<ID, Content>>> {
        ForEach<(Int, Element), ID, CellDragDropView<TaggedView<ID, Content>>>(Array(self.elements.enumerated()),
                                                                               id: { self.mapper($0.1) }) { value, node in
            let (offset, element) = value
            CellDragDropView(content: contentMapper(element, self.mapper(element), node), parentNode: node, index: offset, draggingFunction: action)
        }
    }
}

public extension ForEach where Element : Hashable, ID == Element {
	init(_ elements: [Element], @ViewBuilder _ contentMapper: @escaping (ID) -> Content) {
		self = ForEach(elements, id: {(element: Element) -> Element in element }, contentMapper)
	}
}
