//
//  DocumentGroup.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/8/21.
//

import Foundation

@available(iOS 13, *)
public struct DocumentGroup<Document, Content>: Scene where Content : View {
    @Environment(\.currentStateNode) var currentNode
    let builder: (Document) -> Content
    let documentBuilder: () -> Document
    
    public var body: some Scene {
        WindowGroup {
            builder(documentBuilder())
        }
    }
}
