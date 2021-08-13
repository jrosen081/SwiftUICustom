
import Foundation
import Runtime


protocol Updater {
    func update(value: Any, index: Int)
    func get(valueAtIndex: Int) -> Any
}

public class DOMNode: Updater {
    weak var internalUIView: UIView?
    var uiView: UIView? {
        get {
            internalUIView
        }
        set {
            internalUIView = internalUIView ?? newValue
        }
    }
    var values: [Any] = []
    var environment: EnvironmentValues
    weak var viewController: UIViewController?
    var buildingBlock: _BuildingBlock
    var childNodes: [DOMNode] = []
    
    init(environment: EnvironmentValues, viewController: UIViewController?, buildingBlock: _BuildingBlock) {
        self.environment = environment
        self.viewController = viewController
        self.buildingBlock = buildingBlock
    }
    
    func get(valueAtIndex: Int) -> Any {
        return self.values[valueAtIndex]
    }
    
    func update(value: Any, index: Int) {
        if self.values.count == index {
            values.append(index)
        } else {
            self.values[index] = value
        }
        
        RunLoopInteractor.shared.add(operation: { animation in
            guard let controller = self.viewController, let uiview = self.uiView else { return }
            var newEnvironment = self.environment
            newEnvironment.currentStateNode = self
            newEnvironment.currentAnimation = animation
            self.buildingBlock._redraw(view: uiview, controller: controller, environment: newEnvironment)
        })
    }
    
    func addChild(node: DOMNode, index: Int) {
        if self.childNodes.count == index {
            self.childNodes.append(node)
        } else {
            self.childNodes[index] = node
        }
    }
    
    func node(at index: Int) -> DOMNode? {
        guard self.childNodes.count > index else { return nil }
        return childNodes[index]
    }
}

@dynamicMemberLookup
struct _StateNode<V> {
    let view: V
    let mappedNodes: [(key: String, value: DynamicProperty)]
    let node: DOMNode
    
    init(view: V, node: DOMNode) {
        self.view = view
        self.node = node
        let children = Mirror(reflecting: view).children
        self.mappedNodes = children.compactMap { label, value -> (String, DynamicProperty)? in
            guard let val = label, let dynamic = value as? DynamicProperty else { return nil }
            return (val, dynamic)
        }
    }
    
    func updatedValue() -> V {
        guard let info = try? typeInfo(of: V.self) else { fatalError() }
        var newView = view
        for (offset, node) in mappedNodes.enumerated() {
            var property = node.value
            property.update(with: self.node, index: offset)
            try! info.property(named: node.key).set(value: property, on: &newView)
        }
        return newView
    }
    
    subscript<T>(dynamicMember key: KeyPath<V, T>) -> T {
        return self.updatedValue()[keyPath: key]
    }
}
