//
//  AnyTransition.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/13/20.
//

import Foundation

public struct AnyTransition {
	var performTransition: (_ view: UIView, _ totalSize: CGSize, _ isComingIn: Bool) -> ()
	
	public static let identity = AnyTransition(performTransition: {_,_,_  in })
	public static let opacity = AnyTransition { view,_,_ in
		view.alpha = 0
	}
	
	public static let scale = AnyTransition { view,_,_ in
		view.transform = CGAffineTransform(scaleX: 0, y: 0)
	}
	
	public static let slide = AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
	
	public static func move(edge: Edge) -> AnyTransition {
		AnyTransition {view,size,_ in
			view.transform = edge.toTransform(frame: view.superview?.convert(view.frame, to: nil) ?? .zero, size: size, rToL: UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .rightToLeft)
		}
	}
	
	public static func asymmetric(insertion: AnyTransition, removal: AnyTransition) -> AnyTransition {
		AnyTransition {view,size,comingIn in
			if comingIn {
				insertion.performTransition(view, size, true)
			} else {
				removal.performTransition(view, size, false)
			}
		}
	}
}

public enum Edge {
	case leading, trailing, top, bottom
	
	var rToLEdge: Edge {
		switch self {
		case .leading: return .trailing
		case .trailing: return .leading
		default: return self
		}
	}
	
	func toTransform(frame: CGRect, size: CGSize, rToL: Bool) -> CGAffineTransform {
		let edge = rToL ? self.rToLEdge : self
		switch edge {
		case .leading:
			return CGAffineTransform(translationX: -frame.minX - frame.width, y: 0)
		case .trailing:
            return CGAffineTransform(translationX: size.width, y: 0)
		case .top:
			return CGAffineTransform(translationX: 0, y: -frame.minY - frame.height)
		case .bottom:
			return CGAffineTransform(translationX: 0, y: size.height)
		}
	}
}
