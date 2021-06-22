//
//  PresentationMode.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/21/21.
//

import Foundation

public class PresentationMode {
    public var isPresented: Bool {
        didSet {
            if !isPresented {
                dismiss()
            }
        }
    }
    
    public internal(set) var dismiss: () -> Void
    
    init(isPresented: Bool, dismiss: @escaping () -> Void) {
        self.isPresented = isPresented
        self.dismiss = dismiss
    }
}
