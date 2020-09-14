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
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let label = UILabel(frame: .zero)
		setupData(label: label, environment: environment)
		return SwiftUILabel(label: label)
	}
	
	func setupData(label: UILabel, environment: EnvironmentValues) {
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = text
		label.textAlignment = environment.multilineTextAlignment
		label.textColor = environment.foregroundColor ?? environment.defaultForegroundColor
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = environment.minimumScaleFactor
		label.font = environment.font
		label.allowsDefaultTighteningForTruncation = environment.allowsTightening
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let swiftUILabel = view as? SwiftUILabel else { return }
		setupData(label: swiftUILabel.label, environment: environment)
	}
	
	
}

internal class SwiftUILabel: SwiftUIView {
	let label: UILabel
	override var intrinsicContentSize: CGSize {
		return self.subviews[0].intrinsicContentSize
	}
	
	init(label view: UILabel) {
		self.label = view
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
		view.setContentCompressionResistancePriority(.init(749), for: .horizontal)
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
