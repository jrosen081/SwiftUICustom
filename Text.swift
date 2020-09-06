//
//  Text.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

public struct Text: View {
	let text: String
	
	public init(_ text: String) {
		self.text = text
	}
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = text
		label.textAlignment = .center
		return SwiftUILabel(label: label)
	}
}

internal class SwiftUILabel: SwiftUIView {
	override var intrinsicContentSize: CGSize {
		return self.subviews[0].intrinsicContentSize
	}
	
	init(label view: UILabel) {
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.isUserInteractionEnabled = false
		self.addSubview(view)
		NSLayoutConstraint.activate([
			view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			view.topAnchor.constraint(equalTo: self.topAnchor)
		])
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
