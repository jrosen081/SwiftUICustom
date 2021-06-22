//
//  View.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import UIKit

public protocol View: _BuildingBlock {
	associatedtype Content: View
	var body: Content { get }
}


internal enum LayoutPriority {
    case value(Int)
    case lowest
    case inBetween
    case firm
}

public struct _ViewInfo {
    let isBase: Bool
    let baseBlock: _BuildingBlock
    let layoutPriority: LayoutPriority
}

public protocol _BuildingBlock {
	func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView
	func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues)
    var _viewInfo: _ViewInfo { get }
    func _isEqual(to other: _BuildingBlock) -> Bool
    func _hash(into hasher: inout Hasher)
    func _reset()
    func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize
}

extension _BuildingBlock {
    var _isBase: Bool {
        return _viewInfo.isBase
    }
    var _baseBlock: _BuildingBlock {
        return _viewInfo.baseBlock
    }
}

struct DiffableBuildingBlock: Hashable {
    let buildingBlock: _BuildingBlock
    
    func hash(into hasher: inout Hasher) {
        buildingBlock._hash(into: &hasher)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.buildingBlock._isEqual(to: rhs.buildingBlock)
    }
}

extension Array where Element == _BuildingBlock {
    func isEqual(to rhs: Self) -> Bool {
        let lhs = self
        return lhs.count == rhs.count && zip(lhs, rhs).allSatisfy{ $0.0._isEqual(to: $0.1) }
    }
    
    func hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        self.forEach { $0._hash(into: &hasher) }
    }
    
    func diff(other: Self) -> DiffReturnType {
        var otherMap = Dictionary(grouping: other.map { DiffableBuildingBlock(buildingBlock: $0) }.enumerated(), by: \.1)
        var deletions = [Int]()
        var additions = [Int]()
        var moved = [(from: Int, to: Int)]()
        for (offset, value) in self.enumerated() {
            let representable = DiffableBuildingBlock(buildingBlock: value)
            if var locations = otherMap[representable], let index = locations.first?.offset {
                moved.append((offset, index))
                locations.removeFirst()
                otherMap[representable] = locations
            } else {
                deletions.append(offset)
            }
        }
        otherMap.values.lazy.flatMap({ $0 }).sorted(by: { $0.offset < $1.offset }).forEach {
            additions.append($0.offset)
        }
        return (deletions, additions, moved)
    }
}

typealias DiffReturnType = (deletion: [Int], additions: [Int], moved: [(Int, Int)])

extension View {
    public func _isEqual(to other: _BuildingBlock) -> Bool {
        return other is Self
    }
    public func _hash(into hasher: inout Hasher) {
        ObjectIdentifier(type(of: self)).hash(into: &hasher)
    }
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        self.body._requestedSize(within: size, environment: environment)
    }
    
    public func _reset() {
        if self.body is Self {
            return
        }
        let mirror = Mirror(reflecting: self)
        mirror.children.map { $0.value }
            .compactMap { $0 as? Redrawable }
            .forEach {
                $0.reset()
            }
        self.body._reset()
    }
    
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.body._redraw(view: view, controller: controller, environment: environment)
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let mirror = Mirror(reflecting: self)
		mirror.children.map { $0.value }
			.compactMap { $0 as? EnvironmentNeeded }
			.forEach { $0.environment = environment }
		if let controller = enclosingController as? UpdateDelegate {
			mirror.children.map { $0.value }
				.compactMap { $0 as? Redrawable }
				.forEach {
          $0.addListener(controller)
          Redrawables.redrawables.append(WeakRedrawable(redrawable: $0))
      }
		}
		return self.body._toUIView(enclosingController: enclosingController, environment: environment)
	}
    
    private var _isBase: Bool {
        return self.body is Self
    }
    
    private var _baseBlock: _BuildingBlock {
        return self.body
    }
    
    public var _viewInfo: _ViewInfo {
        return _ViewInfo(isBase: _isBase, baseBlock: _baseBlock, layoutPriority: .lowest)
    }
    
    
    func expanded() -> [_BuildingBlock] {
        return ((self as? BuildingBlockCreator)?.toBuildingBlocks() ?? [self])
            .flatMap { (view) -> [_BuildingBlock] in
                var content = view
                while !content._isBase {
                    content = content._baseBlock
                }
                return (content as? Expandable)?.expanded() ?? [view]
            }
    }
}

struct BuildingBlockRepresentable: View {
    let buildingBlock: _BuildingBlock
    
    var body: Self {
        self
    }
    
    func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        self.buildingBlock._toUIView(enclosingController: enclosingController, environment: environment)
    }
    
    func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        self.buildingBlock._redraw(view: view, controller: controller, environment: environment)
    }
        
    func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        return self.buildingBlock._requestedSize(within: size, environment: environment)
    }
    
}

public func withAnimation<Result>(animation: Animation = .default, operations: () throws -> Result) rethrows -> Result {
  let drawables = Redrawables.redrawables.compactMap { $0.redrawable }
  drawables.forEach { $0.stopRedrawing() }
  let value = try operations()
  drawables.forEach { $0.performAnimation(animation: animation) }
  return value
}

public extension View {
	func modifier<T: ViewModifier>(_ modifier: T) -> ModifiedContent<Self, T> {
		return ModifiedContent(content: self, modification: modifier)
	}
}

public struct ModifiedContent<Content: View, Modification: ViewModifier>: View {
	let content: Content
	let modification: Modification
	
	public var body: Modification.Body {
        self.modification.body(content: _ViewModifier_Content(buildingBlock: self.content))
	}
}

public protocol ViewModifier {
	associatedtype Body: View
	typealias Content = _ViewModifier_Content<Self>
	func body(content: Self.Content) -> Self.Body
}

public struct _ViewModifier_Content<Modifier: ViewModifier>: View {
    let buildingBlock: _BuildingBlock
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        return buildingBlock._toUIView(enclosingController: enclosingController, environment: environment)
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        buildingBlock._redraw(view: view, controller: controller, environment: environment)
	}
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        buildingBlock._requestedSize(within: size, environment: environment)
    }
}
