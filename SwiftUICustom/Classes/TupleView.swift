//
//  TupleView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

protocol BuildingBlockCreator {
	func toBuildingBlocks() -> [BuildingBlock]
}

protocol Expandable {
	func expanded() -> [BuildingBlock]
}

public struct TupleView<T>: BuildingBlockCreator {
	var value: T
	
	public init(value: T) {
		self.value = value
	}
	
	func toBuildingBlocks() -> [BuildingBlock] {
		if let val = self.value as? BuildingBlock {
			return [val]
		}
		
		let buildingBlocks: [BuildingBlock]
		
		if let (c1, c2) = self.value as? (BuildingBlock, BuildingBlock) {
			buildingBlocks = [c1, c2]
		} else if let (c1, c2, c3) = self.value as? (BuildingBlock, BuildingBlock, BuildingBlock) {
			buildingBlocks = [c1, c2, c3]
		} else if let (c1, c2, c3, c4) = self.value as? (BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4]
		} else if let (c1, c2, c3, c4, c5) = self.value as? (BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5]
		} else if let (c1, c2, c3, c4, c5, c6) = self.value as? (BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5, c6]
		} else if let (c1, c2, c3, c4, c5, c6, c7) = self.value as? (BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5, c6, c7]
		} else if let (c1, c2, c3, c4, c5, c6, c7, c8) = self.value as? (BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5, c6, c7, c8]
		} else if let (c1, c2, c3, c4, c5, c6, c7, c8, c9) = self.value as? (BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5, c6, c7, c8, c9]
		} else if let (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10) = self.value as? (BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock, BuildingBlock) {
			buildingBlocks = [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10]
		} else {
			buildingBlocks = []
		}
		return buildingBlocks
	}
}
