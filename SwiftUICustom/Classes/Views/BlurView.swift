//
//  BlurView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/6/21.
//

import Foundation

public struct BlurView<Content: View>: View {
    let content: Content
    let radius: CGFloat
    let isOpaque: Bool
    
    public var body: UIViewWrappingView<Content> {
        UIViewWrappingView(content: content) { blurView in
            let blurEffectsView = UIVisualEffectView(effect: UIBlurEffect(style: isOpaque ? .regular : .light))
            if blurView.subviews.count > 1 {
                blurView.subviews[1].removeFromSuperview()
            }
            blurView.addSubview(blurEffectsView)
            blurView.setupFullConstraints(blurView, blurEffectsView)
        }
    }
}
