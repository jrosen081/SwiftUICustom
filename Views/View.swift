//
//  View.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import UIKit

public protocol View: _View {
	associatedtype Content: View
	var body: Content { get }
}

public protocol _View : _BuildingBlock, Hashable { }

public protocol _BuildingBlock {
	func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView
	func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues)
    var _isBase: Bool { get }
    var _baseBlock: _BuildingBlock { get }
    func _isEqual(to other: _BuildingBlock) -> Bool
    func _hash(into hasher: inout Hasher)
    func _reset()
}

extension View {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.body == rhs.body
    }
    
    public func _hash(into hasher: inout Hasher) {
        return self.hash(into: &hasher)
    }
    
    public func _isEqual(to other: _BuildingBlock) -> Bool {
        if let otherSelf = other as? Self {
            return otherSelf == self
        }
        return false
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
    
    public func hash(into hasher: inout Hasher) {
        self.body.hash(into: &hasher)
    }
    
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.body._redraw(view: view, controller: controller, environment: environment)
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
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
		return self.body.__toUIView(enclosingController: enclosingController, environment: environment)
	}
    
    public var _isBase: Bool {
        return self.body is Self
    }
    
    public var _baseBlock: _BuildingBlock {
        return self.body
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
    
    func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        self.buildingBlock.__toUIView(enclosingController: enclosingController, environment: environment)
    }
    
    func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        self.buildingBlock._redraw(view: view, controller: controller, environment: environment)
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
		self.modification.body(content: _ViewModifier_Content(createView: self.content.__toUIView(enclosingController:environment:), updateView: self.content._redraw(view:controller:environment:)))
	}
}

public protocol ViewModifier {
	associatedtype Body: View
	typealias Content = _ViewModifier_Content<Self>
	func body(content: Self.Content) -> Self.Body
}

public struct _ViewModifier_Content<Modifier: ViewModifier>: View {
	var createView: (UIViewController, EnvironmentValues) -> UIView
	var updateView: (UIView, UIViewController, EnvironmentValues) -> ()
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		return self.createView(enclosingController, environment)
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.updateView(view, controller, environment)
	}
}
