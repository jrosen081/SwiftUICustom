//
//  TupleView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

public struct TupleView<T>{
	var value: T
    
    @Environment(\.currentStateNode) var currentNode
	
	public init(value: T) {
		self.value = value
	}
	
	func toBuildingBlocks() -> [_BuildingBlock] {
		if let val = self.value as? _BuildingBlock {
			return [val]
		}
		
		let buildingBlocks: [_BuildingBlock]
		
		if let (c1, c2) = self.value as? (_BuildingBlock, _BuildingBlock) {
			buildingBlocks = [c1, c2]
		} else if let (c1, c2, c3) = self.value as? (_BuildingBlock, _BuildingBlock, _BuildingBlock) {
			buildingBlocks = [c1, c2, c3]
		} else if let (c1, c2, c3, c4) = self.value as? (_BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4]
		} else if let (c1, c2, c3, c4, c5) = self.value as? (_BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5]
		} else if let (c1, c2, c3, c4, c5, c6) = self.value as? (_BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5, c6]
		} else if let (c1, c2, c3, c4, c5, c6, c7) = self.value as? (_BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5, c6, c7]
		} else if let (c1, c2, c3, c4, c5, c6, c7, c8) = self.value as? (_BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5, c6, c7, c8]
		} else if let (c1, c2, c3, c4, c5, c6, c7, c8, c9) = self.value as? (_BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5, c6, c7, c8, c9]
		} else if let (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10) = self.value as? (_BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock, _BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10]
        } else if let blocks = self.value as? [_BuildingBlock] {
            buildingBlocks = blocks
        } else {
			buildingBlocks = []
		}
		return buildingBlocks
	}
}

extension TupleView : View, _BuildingBlock {
    public var body: ForEach<Int, Int, _BuildingBlockRepresentable> {
        let blocks = toBuildingBlocks()
        return ForEach(Array(0..<blocks.count)) { index in
            _BuildingBlockRepresentable(buildingBlock: blocks[index])
        }
    }
    
    public func _makeSequence(currentNode domNode: DOMNode) -> _ViewSequence {
        let allViewSequences = toBuildingBlocks().enumerated()
            .map { (offset, view) -> _ViewSequence in
            let childNode: DOMNode
            if domNode.childNodes.count > offset {
                childNode = domNode.childNodes[offset]
            } else {
                childNode = type(of: domNode).makeNode(environment: domNode.environment, viewController: domNode.viewController, buildingBlock: view)
                domNode.addChild(node: childNode, index: offset)
            }
            childNode.environment = domNode.environment
            return view._makeSequence(currentNode: childNode)
        }
        return _ViewSequence(count: allViewSequences.map(\.count).reduce(0, +)) { index, node in
            precondition(node === domNode, "How is this possible")
            var indexToUse = index
            var loopCount = 0
            for viewSequence in allViewSequences {
                if indexToUse < viewSequence.count {
                    return viewSequence.viewGetter(indexToUse, node.childNodes[loopCount])
                } else {
                    indexToUse -= viewSequence.count
                }
                loopCount += 1
            }
            fatalError("Bad count")
        }
    }
}
