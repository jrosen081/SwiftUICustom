//
//  OpenUrl.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/21/21.
//

import Foundation

public struct OpenURLAction {
    public func callAsFunction(_ url: URL) {
        self(url) { _ in }
    }
    
    public func callAsFunction(_ url: URL, completion: @escaping (Bool) -> Void) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
