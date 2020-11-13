//
//  TupleView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

protocol BuildingBlockCreator {
	func toBuildingBlocks() -> [_BuildingBlock]
}

protocol Expandable {
	func expanded() -> [_BuildingBlock]
}

public struct TupleView<T>: BuildingBlockCreator {
	var value: T
	
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
