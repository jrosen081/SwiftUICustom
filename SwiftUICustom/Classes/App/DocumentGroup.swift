//
//  DocumentGroup.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/8/21.
//

import Foundation
import UniformTypeIdentifiers

let documentGroupError = NSError(domain: "com.swift.swiftuicustom", code: -2, userInfo:[NSLocalizedDescriptionKey: "Could not access security scoped resource"])

@available(iOS 14, *)
public struct DocumentGroup<Document, Content>: Scene where Content : View {
    @State private var document: Document?
    @State private var url: URL?
    @Environment(\.currentStateNode) public var currentStateNode
    let contentBuilder: (Document, DOMNode, URL?) -> Content
    let contentTypes: [UTType]
    let respondsToDocuments: Bool
    let builder: (URL) throws -> Document
    var isActiveBinding: Binding<Bool> {
        Binding(get: {
            document != nil
        }, set: {_ in document = nil})
    }
    
    @ViewBuilder
    var destination: some View {
        if let document = document {
            contentBuilder(document, currentStateNode, url)
        }
    }
    
    public var body: some Scene {
        WindowGroup {
            DocumentRepresentable(contentTypes: contentTypes, allowsMultipleSelection: false, completion: {
                switch $0 {
                case .success(let urls):
                    guard let first = urls.first else { return }
                    guard first.startAccessingSecurityScopedResource() else { return }
                    self.document = try? builder(first)
                    self.url = first
                    first.stopAccessingSecurityScopedResource()
                default: return
                }
            }, isPresented: Binding<Bool>.constant(true))
            NavigationLink(destination: destination, isActive: isActiveBinding) {
                EmptyView()
            }
        }
    }
    
    public init(newDocument: @autoclosure @escaping () -> Document, editor: @escaping (FileDocumentConfiguration<Document>) -> Content) where Document: FileDocument {
        self.contentTypes = Document.readableContentTypes
        self.respondsToDocuments = false
        self.builder = { url in
            guard url.startAccessingSecurityScopedResource() else { throw documentGroupError }
            defer { url.stopAccessingSecurityScopedResource() }
            let contentType = Document.readableContentTypes.first(where: { $0.preferredFilenameExtension == url.pathExtension }) ?? Document.readableContentTypes.first!
            return try Document(configuration: FileDocumentReadConfiguration(contentType: contentType, file: FileWrapper(url: url, options: [])))
        }
        self.contentBuilder = { document, node, url in
            let contentType = Document.readableContentTypes.first(where: { $0.preferredFilenameExtension == url?.pathExtension }) ?? Document.readableContentTypes.first!
            var configuration = FileDocumentConfiguration(document: document, fileURL: url, isEditable: true, contentType: contentType)
            configuration.update(with: node, index: 3)
            return editor(configuration)
        }
    }
    
    public func _asSequence(domNode: DOMNode, delegate: UIWindowSceneDelegate) -> SceneSequence {
        return SceneSequence(count: 1, sceneGetter: { _, node, delegate in
            let body = _StateNode(view: self, node: node).body
            return (AnyScene(scene: body), node.childNodes.first ?? self.makeNode(parentNode: node, body: body, delegate: delegate))
        })
    }
    
    public func responds(to type: NSUserActivity?) -> Bool {
        guard let _ = type else { return !respondsToDocuments }
        return true
    }
}

protocol SaveableDocument: DynamicProperty {
    func save() throws
}
