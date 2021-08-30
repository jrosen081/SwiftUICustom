//
//  DocumentRepresentable.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/20/21.
//

import Foundation
import UniformTypeIdentifiers

@available(iOS 14, *)
struct DocumentRepresentable: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion, isPresented: isPresented)
    }
    
    let contentTypes: [UTType]
    let allowsMultipleSelection: Bool
    let completion: (Result<[URL], Error>) -> Void
    let isPresented: Binding<Bool>
    
    typealias UIViewControllerType = UIDocumentPickerViewController
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = allowsMultipleSelection
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        uiViewController.allowsMultipleSelection = allowsMultipleSelection
        context.coordinator.completion = completion
        context.coordinator.isPresented = isPresented
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var completion: (Result<[URL], Error>) -> Void
        var isPresented: Binding<Bool>
        
        init(completion: @escaping (Result<[URL], Error>) -> Void, isPresented: Binding<Bool>) {
            self.completion = completion
            self.isPresented = isPresented
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            isPresented.wrappedValue = false
            completion(.success(urls))
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            isPresented.wrappedValue = false
        }
    }
}


@available(iOS 14, *)
public extension View {
    func fileImporter(isPresented: Binding<Bool>, allowedContentTypes: [UTType], allowsMultipleSelection: Bool, onCompletion: @escaping (Result<[URL], Error>) -> Void) -> some View {
        popover(isShowing: isPresented) {
            DocumentRepresentable(contentTypes: allowedContentTypes, allowsMultipleSelection: allowsMultipleSelection, completion: onCompletion, isPresented: isPresented)
        }
    }
}
