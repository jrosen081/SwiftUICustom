//
//  TransformedView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/13/20.
//

import Foundation

extension CGAffineTransform: Hashable {
    public func hash(into hasher: inout Hasher) {
        a.hash(into: &hasher)
        b.hash(into: &hasher)
        c.hash(into: &hasher)
        d.hash(into: &hasher)
        tx.hash(into: &hasher)
        ty.hash(into: &hasher)
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        x.hash(into: &hasher)
        y.hash(into: &hasher)
    }
}

public struct TransformedView<Content: View>: View {
	let content: Content
	let transform: CGAffineTransform
	let anchorPoint: CGPoint
    @Environment(\.self) var environment
    
	public var body: UIViewWrappingView<Content> {
        UIViewWrappingView(content: self.content) { view in
            view.layer.anchorPoint = self.anchorPoint
            let animations = {
                view.transform  = self.transform
            }
            if let animation = environment.currentAnimation {
                UIView.animate(withDuration: animation.duration, delay: animation.delay, options: animation.animationOptions, animations: animations)
            } else {
                animations()
            }
        }
	}
}

public extension View {
	typealias AnchorPoint = CGPoint
	func rotationEffect(_ angle: Angle, anchorPoint: AnchorPoint = .center) -> TransformedView<Self> {
		return TransformedView(content: self, transform: CGAffineTransform(rotationAngle: CGFloat(angle.radians)), anchorPoint: anchorPoint)
	}
	
	func transformEffect(_ transform: CGAffineTransform) -> TransformedView<Self> {
		return TransformedView(content: self, transform: transform, anchorPoint: .center)
	}
    
    func scaleEffect(_ s: CGFloat, anchorPoint: AnchorPoint = .center) -> TransformedView<Self> {
        scaleEffect(x: s, y: s, anchorPoint: anchorPoint)
    }
    
    func scaleEffect(x: CGFloat, y: CGFloat, anchorPoint: AnchorPoint = .center) -> TransformedView<Self> {
        scaleEffect(CGSize(width: x, height: y), anchorPoint: anchorPoint)
    }
    
    func scaleEffect(_ size: CGSize, anchorPoint: AnchorPoint = .center) -> TransformedView<Self> {
        transformEffect(.init(scaleX: size.width, y: size.height ))
    }
}

public extension CGPoint {
	static let bottom = CGPoint(x: 1, y: 0.5)
	static let bottomLeading = CGPoint(x: 1, y: 0)
	static let bottomTrailing = CGPoint(x: 1, y: 1)
	static let top = CGPoint(x: 0, y: 0.5)
	static let topLeading = CGPoint(x: 0, y: 0)
	static let topTrailing = CGPoint(x: 0, y: 1)
	static let center = CGPoint(x: 0.5, y: 0.5)
	static let leading = CGPoint(x: 0.5, y: 0)
	static let trailing = CGPoint(x: 0.5, y: 1)
}
