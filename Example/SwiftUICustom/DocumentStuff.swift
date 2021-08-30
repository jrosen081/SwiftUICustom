//
//  DocumentStuff.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 8/25/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUICustom
import UniformTypeIdentifiers

@available(iOS 14, *)
extension UTType {
    static var exampleText: UTType {
        UTType(importedAs: "com.example.plain-text")
    }
}

@available(iOS 14, *)
struct FakeDocumentDocument: FileDocument {
    var text: String
    
    init(text: String = "Hello, world!") {
        self.text = text
    }
    
    static var readableContentTypes: [UTType] { [.exampleText] }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}

@available(iOS 14, *)
struct FakeDocumentScene: Scene {
    
    var body: some Scene {
        DocumentGroup(newDocument: FakeDocumentDocument()) { config in
            TextField("My document", text: config.$document.text)
        }
    }
}
