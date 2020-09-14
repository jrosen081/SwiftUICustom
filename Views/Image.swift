//
//  Image.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct Image: View {
	let image: UIImage
	
	public init(_ name: String, bundle: Bundle? = nil) {
		self.image = UIImage(named: name, in: bundle, compatibleWith: nil) ?? UIImage()
	}
	
	public init(uiImage: UIImage) {
		self.image = uiImage
	}
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let imageView = UIImageView(frame: .zero)
		updateView(imageView, environment: environment)
		return imageView
	}
	
	func updateView(_ imageView: UIImageView, environment: EnvironmentValues) {
		imageView.image = self.image.withRenderingMode(.alwaysTemplate)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.tintColor = environment.foregroundColor
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		if let imageView = view as? UIImageView {
			updateView(imageView, environment: environment)
		}
	}
}

extension UIImageView {
	override func willExpand(in context: ExpandingContext) -> Bool {
		return true
	}
}
