//
//  FileDocument.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/8/21.
//

import Foundation
import UniformTypeIdentifiers

@available(iOS 14, *)
public protocol FileDocument {
    init(configuration: Self.ReadConfiguration) throws
    func fileWrapper(configuration: Self.WriteConfiguration) throws -> FileWrapper
    typealias ReadConfiguration = FileDocumentReadConfiguration
    typealias WriteConfiguration = FileDocumentWriteConfiguration
    static var readableContentTypes: [UTType] { get }
    static var writableContentTypes: [UTType] { get }
}

@available(iOS 14, *)
public extension FileDocument {
    static var writableContentTypes: [UTType] { readableContentTypes }
}

@available(iOS 14, *)
public struct FileDocumentReadConfiguration {
    public let contentType: UTType
    public let file: FileWrapper
}

@available(iOS 14, *)
public struct FileDocumentWriteConfiguration {
    public let contentType: UTType
    public let existingFile: FileWrapper?
}

private class DocumentDOMNode: DOMNode {
    var save: (() -> Void)?
    override func update(value: Any, index: Int, shouldRedraw: Bool = false) {
        super.update(value: value, index: index, shouldRedraw: shouldRedraw)
        self.save?()
    }
}


@available(iOS 14, *)
public struct FileDocumentConfiguration<Document>: SaveableDocument where Document : FileDocument {
    @State public var document: Document
    public var fileURL: URL?
    public var isEditable: Bool
    let contentType: UTType
    
    func save() throws {
        let writeConfiguration = try FileDocumentWriteConfiguration(contentType: self.contentType, existingFile: self.fileURL.map { try FileWrapper(url: $0, options: []) })
        let wrapper = try self.document.fileWrapper(configuration: writeConfiguration)
        try wrapper.write(to: self.fileURL ?? FileManager.default.temporaryDirectory.appendingPathComponent("temp").appendingPathExtension(self.contentType.preferredFilenameExtension ?? ""), options: [], originalContentsURL: self.fileURL)
    }
    
    public mutating func update(with node: DOMNode, index: Int) {
        let documentDOMNode = node.node(at: 0) as? DocumentDOMNode ?? DocumentDOMNode(environment: node.environment, viewController: node.viewController, buildingBlock: node.buildingBlock)
        self._document.update(with: documentDOMNode, index: 0)
        let internalSelf = self
        documentDOMNode.save = {
            do {
                try internalSelf.save()
            } catch {
                print(error)
            }
        }
    }
}

@available(iOS 14, *)
public protocol ReferenceFileDocument: ObservableObject {
    associatedtype Snapshot
    init(configuration: Self.ReadConfiguration) throws
    func fileWrapper(snapshot: Snapshot, configuration: Self.WriteConfiguration) throws -> FileWrapper
    func snapshot(contentType: UTType) throws -> Self.Snapshot
    typealias ReadConfiguration = FileDocumentReadConfiguration
    typealias WriteConfiguration = FileDocumentWriteConfiguration
    static var readableContentTypes: [UTType] { get }
    static var writableContentTypes: [UTType] { get }
}

@available(iOS 14, *)
public extension ReferenceFileDocument {
    static var writableContentTypes: [UTType] { readableContentTypes }
}

@available(iOS 14, *)
public struct ReferenceFileDocumentConfiguration<Document>: SaveableDocument where Document : ReferenceFileDocument {
    @ObservedObject public var document: Document
    let contentType: UTType
    public var fileURL: URL?
    public var isEditable: Bool
    
    func save() throws {
        let snapshot = try self.document.snapshot(contentType: self.contentType)
        let configuration = try FileDocumentWriteConfiguration(contentType: self.contentType, existingFile: self.fileURL.map { try FileWrapper(url: $0, options: []) })
        let wrapper = try self.document.fileWrapper(snapshot: snapshot, configuration: configuration)
        try wrapper.write(to: self.fileURL ?? FileManager.default.temporaryDirectory.appendingPathComponent("temp").appendingPathExtension(self.contentType.preferredFilenameExtension ?? ""), options: [], originalContentsURL: self.fileURL)
    }

    public mutating func update(with node: DOMNode, index: Int) {
        let documentDOMNode = node.node(at: 0) as? DocumentDOMNode ?? DocumentDOMNode(environment: node.environment, viewController: node.viewController, buildingBlock: node.buildingBlock)
        self._document.update(with: documentDOMNode, index: 0)
        let internalSelf = self
        documentDOMNode.save = {
            do {
                try internalSelf.save()
            } catch {
                print(error)
            }
        }
    }
}
