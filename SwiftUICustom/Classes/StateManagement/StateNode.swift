
import Foundation
import Runtime


protocol Updater {
    func update(value: Any, index: Int, shouldRedraw: Bool)
    func get(valueAtIndex: Int) -> Any
}

public class DOMNode: NSObject, Updater {
    weak var parent: DOMNode?
    weak var internalUIView: UIView? {
        didSet {
            self.shouldRestartValue = false
            onViewChange?(internalUIView)
        }
    }

    @objc func listenForDeallocations(notification: Notification) {
        DispatchQueue.main.async {
            self.shouldRestartValue = self.viewController == nil
        }
    }

    var uiView: UIView? {
        get {
            internalUIView
        }
        set {
            internalUIView = internalUIView ?? newValue
        }
    }
    
    var shouldRestartValue: Bool = true {
        didSet {
            onRedrawChange?(shouldRestartValue)
        }
    }
    var values: [Any] = []
    var environment: EnvironmentValues
    weak var viewController: UIViewController?
    var buildingBlock: _BuildingBlock
    var childNodes: [DOMNode] = []
    
    var onViewChange: ((UIView?) -> Void)?
    var onRedrawChange: ((Bool) -> Void)?
    
    init(environment: EnvironmentValues, viewController: UIViewController?, buildingBlock: _BuildingBlock) {
        self.environment = environment
        self.viewController = viewController
        self.buildingBlock = buildingBlock
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(listenForDeallocations), name: swiftUIControllerDeallocatedNotification, object: nil)
    }
    
    func get(valueAtIndex: Int) -> Any {
        return self.values[valueAtIndex]
    }
    
    func safeGet(valueAtIndex: Int) -> Any? {
        if self.values.count > valueAtIndex {
            return get(valueAtIndex: valueAtIndex)
        } else {
            return nil
        }
    }
    
    func update(value: Any, index: Int, shouldRedraw: Bool = false) {
        if self.values.count == index {
            values.append(index)
        } else {
            self.values[index] = value
        }
        self.shouldRestartValue = false
        guard shouldRedraw else { return }
        RunLoopInteractor.shared.add(operation: { [weak self] animation in
            print("Updating node \(ObjectIdentifier(self!)) with updated value \(value)")
            self?.redraw(animation: animation)
        })
    }
    
    func addChild(node: DOMNode, index: Int) {
        if self.childNodes.count == index {
            self.childNodes.append(node)
        } else {
            self.childNodes[index] = node
        }
        node.parent = self
    }
    
    func node(at index: Int) -> DOMNode? {
        guard self.childNodes.count > index else { return nil }
        return childNodes[index]
    }
    
    func redraw(animation: Animation?) {
        guard let controller = self.viewController, let uiview = self.uiView else {
            if !shouldRestartValue, let parent = self.parent {
                parent.redraw(animation: animation)
            }
            return
        }
        var newEnvironment = self.environment
        newEnvironment.currentStateNode = self
        newEnvironment.currentAnimation = animation
        self.buildingBlock._redraw(view: uiview, controller: controller, environment: newEnvironment)
    }
    
    class func makeNode(environment: EnvironmentValues, viewController: UIViewController?, buildingBlock: _BuildingBlock) -> DOMNode {
        return DOMNode(environment: environment, viewController: viewController, buildingBlock: buildingBlock)
    }
}

private protocol OptionalType {}
extension Optional: OptionalType {}

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
            guard let val = label, let dynamic = value as? DynamicProperty, (value as? OptionalType) == nil else { return nil }
            return (val, dynamic)
        }
    }
    
    func updatedValue() -> V {
        guard let info = try? typeInfo(of: type(of: view).self) else { fatalError() }
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
