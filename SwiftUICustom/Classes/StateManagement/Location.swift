//
//  Location.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/22/21.
//

import Foundation

struct Location<Value> {
    let index: Int
    let node: Updater
    
    var value: Value {
        get {
            return node.get(valueAtIndex: index) as! Value
        }
        
        nonmutating set {
            node.update(value: newValue, index: index, shouldRedraw: true)
        }
    }
}
