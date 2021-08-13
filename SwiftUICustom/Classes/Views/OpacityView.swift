//
//  OpacityView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/6/21.
//

import Foundation

public struct OpacityView<Content: View>: View {
    let content: Content
    let brightness: Double
    @Environment(\.currentAnimation) var animation
    
    public var body: UIViewWrappingView<Content> {
        UIViewWrappingView(content: content) { view in
            let animation = animation ?? Animation(animationOptions: [], delay: 0, duration: 0, repeatsForever: false, repeatCount: 0)
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animation.duration, delay: animation.delay, options: animation.animationOptions, animations: {
                view.alpha = CGFloat(brightness)
            })
        }
    }
}

public extension View {
    func opacity(_ val: Double) -> OpacityView<Self> {
        OpacityView(content: self, brightness: val)
    }
}
