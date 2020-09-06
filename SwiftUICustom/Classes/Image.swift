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
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let imageView = UIImageView(image: self.image.withRenderingMode(.alwaysTemplate))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		return imageView
	}
}
