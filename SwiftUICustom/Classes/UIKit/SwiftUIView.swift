//
//  SwiftUIView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

internal class SwiftUIView: UIView {
    var onDisappear: (() -> Void)? = nil
    
    override func didMoveToSuperview() {
        if self.superview == nil, let onDisappear = self.onDisappear {
            DispatchQueue.main.async(execute: onDisappear)
        }
    }
}
