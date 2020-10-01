//
//  ListStyle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/1/20.
//

import Foundation

public protocol ListStyle {
    var _tableViewStyle: UITableView.Style { get }
}

public struct DefaultListStyle: ListStyle {
    public init() {}
    
    public var _tableViewStyle: UITableView.Style {
        return .plain
    }
}

public struct GroupedListStyle : ListStyle {
    public init() {}
    public var _tableViewStyle: UITableView.Style {
        return .grouped
    }
}

public typealias PlainListStyle = DefaultListStyle

@available(iOS 13.0, *)
public struct InsetGroupedListStyle: ListStyle {
    public init() {}
    public var _tableViewStyle: UITableView.Style {
        return .insetGrouped
    }
}
