
import Foundation
import Runtime

@dynamicMemberLookup
struct StateNode<V: View> {
    let view: V
    let mappedNodes: [String: DynamicProperty]
    
    init(view: V) {
        self.view = view
        let children = Mirror(reflecting: view).children
        self.mappedNodes = Dictionary(uniqueKeysWithValues: children.compactMap { label, value -> (String, DynamicProperty)? in
            guard let val = label, let dynamic = value as? DynamicProperty else { return nil }
            return (val, dynamic)
        })
    }
    
    subscript<T>(dynamicMember key: KeyPath<V, T>) -> T {
        guard let info = try? typeInfo(of: V.self) else { fatalError() }
        var newView = view
        for node in mappedNodes {
            var property = node.value
            property.update()
            try? info.property(named: node.key).set(value: property, on: &newView)
        }
        return newView[keyPath: key]
    }
}
