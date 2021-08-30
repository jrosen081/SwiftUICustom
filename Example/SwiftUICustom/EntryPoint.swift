//
//  EntryPoint.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 6/21/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUICustom

class Delegate: NSObject, UIApplicationDelegate {
}

struct FakeScene: Scene {
    @State var value = 0
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            SampleView(exampleModelFromApp: $value)
        }
        WindowGroup {
            Text("Make sure this does not happen")
        }
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(Delegate.self)
    var delegate
    
    @StateObject var checkThis = ExampleModel()
    
    var scene: some Scene {
//        if #available(iOS 14, *) {
//            return FakeDocumentScene()
//        } else {
//            fatalError()
//        }
        FakeScene()
        .onChange(of: checkThis.value) {
            print($0)
        }
    }
}
