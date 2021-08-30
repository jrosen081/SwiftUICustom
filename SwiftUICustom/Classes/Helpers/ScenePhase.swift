//
//  ScenePhase.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/25/21.
//

import Foundation

public enum ScenePhase: Equatable {
    case active, inactive, background
}

struct ScenePhaseKey: EnvironmentKey {
    static var defaultValue: ScenePhase = .background
}

public extension EnvironmentValues {
    var scenePhase: ScenePhase {
        get {
            self[ScenePhaseKey.self]
        }
        set {
            self[ScenePhaseKey.self] = newValue
        }
    }
}
