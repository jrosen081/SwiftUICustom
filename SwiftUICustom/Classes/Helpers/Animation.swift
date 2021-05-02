//
//  Animation.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/13/20.
//

import Foundation

extension UIView.AnimationOptions: Hashable {
    public func hash(into hasher: inout Hasher) {
        self.rawValue.hash(into: &hasher)
    }
}

public struct Animation: Hashable {
	var animationOptions: UIView.AnimationOptions
	var delay: Double
	var duration: Double
	var repeatsForever: Bool
	var repeatCount: Int
	var autoReverses: Bool = false
	
	public func delay(_ delay: Double) -> Animation {
		var newVal = self
		newVal.delay = delay
		return newVal
	}
	
	public func repeatCount(_ count: Int, autoreverses: Bool) -> Animation {
		var newVal = self
		newVal.repeatCount = count
		newVal.autoReverses = autoreverses
		return newVal
	}
	
	public func repeatForever(autoreverses: Bool) -> Animation {
		var newVal = self
		newVal.repeatsForever = true
		newVal.autoReverses = autoreverses
		return newVal
	}
	
	public func speed(_ percent: Double) -> Animation {
		var newVal = self
		newVal.duration = newVal.duration / percent
		return newVal
	}
	
	public static let `default` = Animation(animationOptions: [], delay: 0, duration: 0.33, repeatsForever: false, repeatCount: 0)
	
	public static let easeIn = Animation(animationOptions: .curveEaseIn, delay: 0, duration: 0.33, repeatsForever: false, repeatCount: 0)
	public static let easeInOut = Animation(animationOptions: .curveEaseInOut, delay: 0, duration: 0.33, repeatsForever: false, repeatCount: 0)
	public static let easeOut = Animation(animationOptions: .curveEaseOut, delay: 0, duration: 0.33, repeatsForever: false, repeatCount: 0)
	public static let linear = Animation(animationOptions: .curveLinear, delay: 0, duration: 0.33, repeatsForever: false, repeatCount: 0)
	
	public static func easeIn(duration: Double) -> Animation {
		return Animation(animationOptions: .curveEaseIn, delay: 0, duration: duration, repeatsForever: false, repeatCount: 0)
	}
	
	public static func easeInOut(duration: Double) -> Animation {
		return Animation(animationOptions: .curveEaseInOut, delay: 0, duration: duration, repeatsForever: false, repeatCount: 0)
	}
	
	public static func easeOut(duration: Double) -> Animation {
		return Animation(animationOptions: .curveEaseOut, delay: 0, duration: duration, repeatsForever: false, repeatCount: 0)
	}
	
	public static func linear(duration: Double) -> Animation {
		return Animation(animationOptions: .curveLinear, delay: 0, duration: duration, repeatsForever: false, repeatCount: 0)
	}
}
