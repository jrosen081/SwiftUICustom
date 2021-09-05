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

public struct _ViewSequence {
    let count: Int
    let viewGetter: (Int, DOMNode) -> (_BuildingBlockRepresentable, DOMNode)
    
    func expanded(node: DOMNode) -> [(_BuildingBlockRepresentable, DOMNode)] {
        return (0..<count).map { viewGetter($0, node) }
    }
}

public protocol _BuildingBlock {
	func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView
	func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues)
    var _viewInfo: _ViewInfo { get }
    func _isEqual(to other: _BuildingBlock) -> Bool
    func _hash(into hasher: inout Hasher)
    func _makeSequence(currentNode: DOMNode) -> _ViewSequence
}

extension _BuildingBlock {
    var _isBase: Bool {
        return _viewInfo.isBase
    }
    var _baseBlock: _BuildingBlock {
        return _viewInfo.baseBlock
    }
    
    var textValue: String? {
        if let text = self as? Text {
            return text.text
        }
        
        if let label = self as? Label<Text, Image>, case let .titleIcon(title, _) = label.storage {
            return title.text
        }
        
        return nil
    }
    
    var imageValue: UIImage? {
        if let image = self as? Image {
            return image.image
        }
        
        if let label = self as? Label<Text, Image>, case let .titleIcon(_, image) = label.storage {
            return image.image
        }
        
        return nil

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
        
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let stateNode = _StateNode(view: self, node: environment.currentStateNode)
        environment.currentStateNode.environment = environment
        let newNode = environment.currentStateNode.childNodes[0]
        var newEnvironment = environment
        newEnvironment.currentStateNode = newNode
        stateNode.body._redraw(view: view, controller: controller, environment: newEnvironment)
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let node = environment.currentStateNode
        let stateNode = _StateNode(view: self, node: node)
        let body = stateNode.body
        let newNode = node.node(at: 0) ?? type(of: environment.currentStateNode).makeNode(environment: environment, viewController: enclosingController, buildingBlock: body)
        node.addChild(node: newNode, index: 0)
        var newEnvironment = environment
        newEnvironment.currentStateNode = newNode
        node.viewController = enclosingController
		let view = body._toUIView(enclosingController: enclosingController, environment: newEnvironment)
        node.uiView = view
        return view
	}
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        if self._isBase {
            return _ViewSequence(count: 1, viewGetter: {_, node in
                return (_BuildingBlockRepresentable(buildingBlock: self), node)
                
            })
        } else {
            let body = _StateNode(view: self, node: currentNode).body
            let childNode = currentNode.childNodes.first ?? type(of: currentNode).makeNode(environment: currentNode.environment, viewController: currentNode.viewController, buildingBlock: body)
            childNode.environment = currentNode.environment.withUpdates { $0.currentStateNode = childNode }
            currentNode.addChild(node: childNode, index: 0)
            childNode.onViewChange = {[weak currentNode] view in
                currentNode?.uiView = view
            }
            childNode.onRedrawChange = {[weak currentNode] shouldRestart in
                currentNode?.shouldRestartValue = shouldRestart
            }
            let childSequence = body._makeSequence(currentNode: childNode)
            return _ViewSequence(count: childSequence.count) { index, node in
                precondition(node === currentNode, "\(type(of: self))")
                let newNode = node.childNodes[0]
                newNode.environment = currentNode.environment.withUpdates { $0.currentStateNode = newNode }
                return childSequence.viewGetter(index, newNode)
            }
        }
    }
    
    internal var _isBase: Bool {
        return Content.self == Self.self || Content.self == Never.self
    }
    
    private var _baseBlock: _BuildingBlock {
        return Content.self == Never.self ? self : self.body
    }
    
    public var _viewInfo: _ViewInfo {
        return _ViewInfo(isBase: _isBase, baseBlock: _baseBlock, layoutPriority: .lowest)
    }
}

public struct _BuildingBlockRepresentable: View {
    let buildingBlock: _BuildingBlock
    
    var text: String? {
        return buildingBlock.textValue
    }
    
    var image: UIImage? {
        return buildingBlock.imageValue
    }
    
    public var body: Self {
        self
    }
    
    public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        environment.currentStateNode.buildingBlock = buildingBlock
        let view = self.buildingBlock._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = view
        return view
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        self.buildingBlock._redraw(view: view, controller: controller, environment: environment)
    }
    
    public func _isEqual(to other: _BuildingBlock) -> Bool {
        guard let other = other as? Self else { return false }
        return other.buildingBlock._isEqual(to: self.buildingBlock)
    }
    
    public func _hash(into hasher: inout Hasher) {
        self.buildingBlock._hash(into: &hasher)
    }
}

public func withAnimation<Result>(animation: Animation = .default, operations: () throws -> Result) rethrows -> Result {
    RunLoopInteractor.shared.updateAnimation(animation)
    let value = try operations()
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
        environment.currentStateNode.buildingBlock = buildingBlock
        let view = buildingBlock._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = view
        return view
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        buildingBlock._redraw(view: view, controller: controller, environment: environment)
	}
}
