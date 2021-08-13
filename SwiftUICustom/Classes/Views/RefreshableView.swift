//
//  RefreshableView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/20/21.
//

import Foundation

public struct RefreshAction {
    let action: (Completion) -> Void
    
    public func callAsFunction(completion: @escaping () -> Void) {
        action(Completion(completion: completion))
    }
}

public struct Completion {
    let completion: () -> Void
    public func callAsFunction() {
        completion()
    }
}

public extension View {
    func refreshable(action: @escaping (Completion) -> Void) -> EnvironmentUpdatingView<Self> {
        EnvironmentUpdatingView(content: self) { $0.refreshAction = RefreshAction(action: action) }
    }
}
