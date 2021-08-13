//
//  SceneBuilder.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/3/21.
//

import Foundation

@available(iOS 13, *)
@resultBuilder
public struct SceneBuilder {
    public static func buildBlock<S: Scene>(_ s: S) -> S {
        return s
    }
    
    public static func buildBlock<S1: Scene, S2: Scene>(_ s1: S1, _ s2: S2) -> SceneTupleView<(S1, S2)> {
        .init(scenes: [AnyScene(scene: s1), AnyScene(scene: s2)])
    }
    
    public static func buildBlock<S1: Scene, S2: Scene, S3: Scene>(_ s1: S1, _ s2: S2, _ s3: S3) -> SceneTupleView<(S1, S2, S3)> {
        .init(scenes: [AnyScene(scene: s1), AnyScene(scene: s2), AnyScene(scene: s3)])
    }
    
    public static func buildBlock<S1: Scene, S2: Scene, S3: Scene, S4: Scene>(_ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> SceneTupleView<(S1, S2, S3, S4)> {
        .init(scenes: [AnyScene(scene: s1), AnyScene(scene: s2), AnyScene(scene: s3), AnyScene(scene: s4)])
    }

    public static func buildBlock<S1: Scene, S2: Scene, S3: Scene, S4: Scene, S5: Scene>(_ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5) -> SceneTupleView<(S1, S2, S3, S4, S5)> {
        .init(scenes: [AnyScene(scene: s1), AnyScene(scene: s2), AnyScene(scene: s3), AnyScene(scene: s4), AnyScene(scene: s5)])
    }

    
    public static func buildBlock<S1: Scene, S2: Scene, S3: Scene, S4: Scene, S5: Scene, S6: Scene>(_ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6) -> SceneTupleView<(S1, S2, S3, S4, S5, S6)> {
        .init(scenes: [AnyScene(scene: s1), AnyScene(scene: s2), AnyScene(scene: s3), AnyScene(scene: s4), AnyScene(scene: s5), AnyScene(scene: s6)])
    }

    public static func buildBlock<S1: Scene, S2: Scene, S3: Scene, S4: Scene, S5: Scene, S6: Scene, S7: Scene>(_ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7) -> SceneTupleView<(S1, S2, S3, S4, S5, S6, S7)> {
        .init(scenes: [AnyScene(scene: s1), AnyScene(scene: s2), AnyScene(scene: s3), AnyScene(scene: s4), AnyScene(scene: s5), AnyScene(scene: s6), AnyScene(scene: s7)])
    }

    public static func buildBlock<S1: Scene, S2: Scene, S3: Scene, S4: Scene, S5: Scene, S6: Scene, S7: Scene, S8: Scene>(_ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8) -> SceneTupleView<(S1, S2, S3, S4, S5, S6, S7, S8)> {
        .init(scenes: [AnyScene(scene: s1), AnyScene(scene: s2), AnyScene(scene: s3), AnyScene(scene: s4), AnyScene(scene: s5), AnyScene(scene: s6), AnyScene(scene: s7), AnyScene(scene: s8)])
    }

    public static func buildBlock<S1: Scene, S2: Scene, S3: Scene, S4: Scene, S5: Scene, S6: Scene, S7: Scene, S8: Scene, S9: Scene>(_ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9) -> SceneTupleView<(S1, S2, S3, S4, S5, S6, S7, S8, S9)> {
        .init(scenes: [AnyScene(scene: s1), AnyScene(scene: s2), AnyScene(scene: s3), AnyScene(scene: s4), AnyScene(scene: s5), AnyScene(scene: s6), AnyScene(scene: s7), AnyScene(scene: s8), AnyScene(scene: s9)])
    }

    public static func buildBlock<S1: Scene, S2: Scene, S3: Scene, S4: Scene, S5: Scene, S6: Scene, S7: Scene, S8: Scene, S9: Scene, S10: Scene>(_ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9, _ s10: S10) -> SceneTupleView<(S1, S2, S3, S4, S5, S6, S7, S8, S9, S10)> {
        .init(scenes: [AnyScene(scene: s1), AnyScene(scene: s2), AnyScene(scene: s3), AnyScene(scene: s4), AnyScene(scene: s5), AnyScene(scene: s6), AnyScene(scene: s7), AnyScene(scene: s8), AnyScene(scene: s9), AnyScene(scene: s10)])
    }

}


@available(iOS 13.0.0, *)
public struct SceneTupleView<Value>: Scene {
    let scenes: [AnyScene]
    
    public var body: Never {
        fatalError()
    }
    
    public func _asSequence(domNode: DOMNode, delegate: UIWindowSceneDelegate) -> SceneSequence {
        let allSceneSequences = scenes.enumerated().map { (offset, scene) -> SceneSequence in
            let childNode: DOMNode
            if domNode.childNodes.count > offset {
                childNode = domNode.childNodes[offset]
            } else {
                childNode = self.makeNode(parentNode: domNode, body: scene, delegate: delegate, index: offset)
            }
            return scene._asSequence(domNode: childNode, delegate: delegate)
        }
        return SceneSequence(count: allSceneSequences.map(\.count).reduce(0, +)) { index, node, delegate in
            var indexToUse = index
            var loopCount = 0
            for sceneSequence in allSceneSequences {
                if indexToUse < sceneSequence.count {
                    return sceneSequence.sceneGetter(indexToUse, node.childNodes[loopCount], delegate)
                } else {
                    indexToUse -= sceneSequence.count
                }
                loopCount += 1
            }
            fatalError("Bad count")
        }
    }
}

@available(iOS 13, *)
public struct SceneSequence {
    let count: Int
    let sceneGetter: (Int, DOMNode, UIWindowSceneDelegate) -> (AnyScene, DOMNode)
}
