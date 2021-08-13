//
//  FileDocument.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/8/21.
//

import Foundation

public protocol FileDocument {
    init(configuration: Self.ReadConfiguration) throws
    func fileWrapper(configuration: Self.WriteConfiguration) throws -> FileWrapper
    typealias ReadConfiguration = FileDocumentReadConfiguration
    typealias WriteConfiguration = FileDocumentWriteConfiguration
    static var readableContentTypes: [String] { get }
    static var writableContentTypes: [String] { get }
}

public extension FileDocument {
    static var writableContentTypes: [String] { readableContentTypes }
}

public struct FileDocumentReadConfiguration {
    public let contentType: String
    public let file: FileWrapper
}

public struct FileDocumentWriteConfiguration {
    public let contentType: String
    public let existingFile: FileWrapper?
}

public struct FileDocumentConfiguration<Document> where Document : FileDocument {
    @State public var document: Document
    public var fileURL: URL?
    public var isEditable: Bool
}


public protocol ReferenceFileDocument: ObservableObject {
    associatedtype Snapshot
    init(configuration: Self.ReadConfiguration) throws
    func fileWrapper(snapshot: Snapshot, configuration: Self.WriteConfiguration) throws -> FileWrapper
    func snapshot(contentType: String) throws -> Self.Snapshot
    typealias ReadConfiguration = FileDocumentReadConfiguration
    typealias WriteConfiguration = FileDocumentWriteConfiguration
    static var readableContentTypes: [String] { get }
    static var writableContentTypes: [String] { get }
}

public extension ReferenceFileDocument {
    static var writableContentTypes: [String] { readableContentTypes }
}

public struct ReferenceFileDocumentConfiguration<Document> where Document : ReferenceFileDocument {
    @ObservedObject public var document: Document
    public var fileURL: URL?
    public var isEditable: Bool
}

protocol Document: DynamicProperty {
    func save() throws
    static var readableContentTypes: [String] { get }
    static var writableContentTypes: [String] { get }
}
