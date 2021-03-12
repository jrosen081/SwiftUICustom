//
//  ZStack.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct ZStack<Content: View>: View {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.alignment == rhs.alignment && lhs.contentBuilder == rhs.contentBuilder
    }
    
    public func hash(into hasher: inout Hasher) {
        contentBuilder.hash(into: &hasher)
        alignment.hash(into: &hasher)
    }
    
	let contentBuilder: Content
	let alignment: Alignment
	
	public init(alignment: Alignment = .center, @ViewBuilder contentBuilder: () -> Content) {
		self.contentBuilder = contentBuilder()
		self.alignment = alignment
	}
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let enclosingView = SwiftUIView(frame: .zero)
		enclosingView.translatesAutoresizingMaskIntoConstraints = false
		let view = contentBuilder.__toUIView(enclosingController: enclosingController, environment: environment)
		((view as? InternalCollatedView)?.underlyingViews ?? [view]).enumerated().forEach { (index, underlyingView) in
			if index == 0 {
				enclosingView.addSubview(underlyingView)
				NSLayoutConstraint.activate([
					underlyingView.leadingAnchor.constraint(equalTo: enclosingView.leadingAnchor),
					underlyingView.trailingAnchor.constraint(equalTo: enclosingView.trailingAnchor),
					underlyingView.topAnchor.constraint(equalTo: enclosingView.topAnchor),
					underlyingView.bottomAnchor.constraint(equalTo: enclosingView.bottomAnchor)
				])
				return
			}
			enclosingView.addSubview(underlyingView)
			NSLayoutConstraint.activate([
				self.alignment.horizontalAlignment.toAnchor(inView: underlyingView).constraint(equalTo: self.alignment.horizontalAlignment.toAnchor(inView: enclosingView)),
				self.alignment.verticalAlignment.toAnchor(inView: underlyingView).constraint(equalTo: self.alignment.verticalAlignment.toAnchor(inView: enclosingView)),
				underlyingView.widthAnchor.constraint(lessThanOrEqualTo: enclosingView.widthAnchor, multiplier: 1),
				underlyingView.heightAnchor.constraint(lessThanOrEqualTo: enclosingView.heightAnchor, multiplier: 1),
			])
		}
		return enclosingView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		let viewProtocol = contentBuilder
		guard let buildingBlockCreator = viewProtocol as? BuildingBlockCreator else { return }
		zip(view.subviews, buildingBlockCreator.toBuildingBlocks().expanded()).forEach {
			$1._redraw(view: $0, controller: controller, environment: environment)
		}
	}
}