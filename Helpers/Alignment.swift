//
//  Alignment.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct Alignment: Hashable {
	let horizontalAlignment: HorizontalAlignment
	let verticalAlignment: VerticalAlignment
	
	public static let center = Alignment(horizontalAlignment: .center, verticalAlignment: .center)
	public static let topLeading = Alignment(horizontalAlignment: .leading, verticalAlignment: .top)
	public static let top = Alignment(horizontalAlignment: .center, verticalAlignment: .top)
	public static let topTrailing = Alignment(horizontalAlignment: .trailing, verticalAlignment: .top)
	public static let leading = Alignment(horizontalAlignment: .leading, verticalAlignment: .center)
	public static let trailing = Alignment(horizontalAlignment: .trailing, verticalAlignment: .center)
	public static let bottomLeading = Alignment(horizontalAlignment: .leading, verticalAlignment: .bottom)
	public static let bottom = Alignment(horizontalAlignment: .center, verticalAlignment: .bottom)
	public static let bottomTrailing = Alignment(horizontalAlignment: .trailing, verticalAlignment: .bottom)
}

public enum HorizontalAlignment {
	case center, leading, trailing
	
	func toAnchor(inView view: UIView) -> NSLayoutAnchor<NSLayoutXAxisAnchor> {
		switch self {
		case .center: return view.centerXAnchor
		case .leading: return view.leadingAnchor
		case .trailing: return view.trailingAnchor
		}
	}
	
	var stackViewAlignment: UIStackView.Alignment {
		switch self {
		case .center: return .center
		case .leading: return .leading
		case .trailing: return .trailing
		}
	}
}

public enum VerticalAlignment {
	case top, center, bottom
	func toAnchor(inView view: UIView) -> NSLayoutAnchor<NSLayoutYAxisAnchor> {
		switch self {
		case .top: return view.topAnchor
		case .center: return view.centerYAnchor
		case .bottom: return view.bottomAnchor
		}
	}
	
	var stackViewAlignment: UIStackView.Alignment {
		switch self {
		case .center: return .center
		case .top: return .top
		case .bottom: return .bottom
		}
	}
}
