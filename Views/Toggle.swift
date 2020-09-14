//
//  Toggle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/9/20.
//

import Foundation

public struct Toggle<Label: View>: View {
	let creation: () -> Label
	let isOn: Binding<Bool>
	
	public init(isOn: Binding<Bool>, @ViewBuilder creation: @escaping () -> Label) {
		self.creation = creation
		self.isOn = isOn
	}
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let toggle = SwiftUISwitch(binding: self.isOn)
		toggle.onTintColor = environment.foregroundColor ?? .systemGreen
		let swiftUIStackView = SwiftUIStackView(arrangedSubviews: [self.creation()._toUIView(enclosingController: enclosingController, environment: environment), ExpandingView(), toggle], context: .horizontal)
		swiftUIStackView.translatesAutoresizingMaskIntoConstraints = false
		swiftUIStackView.axis = .horizontal
		swiftUIStackView.alignment = .center
		return swiftUIStackView
	}
	
	public func _redraw(view internalView: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let view = internalView as? UIStackView else { return }
		self.creation()._redraw(view: view.arrangedSubviews[0], controller: controller, environment: environment)
	}
}

class SwiftUISwitch: UISwitch, UpdateDelegate {
	let binding: Binding<Bool>
	
	init(binding: Binding<Bool>) {
		self.binding = binding
		super.init(frame: .zero)
		binding.addListener(self)
		self.isOn = binding.wrappedValue
		self.addTarget(self, action: #selector(self.changedValue), for: .valueChanged)
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateData(with animation: Animation?) {
		guard self.binding.wrappedValue != self.isOn else { return }
		self.setOn(self.binding.wrappedValue, animated: true)
	}
	
	@objc func changedValue() {
		guard self.binding.wrappedValue != self.isOn else { return }
		DispatchQueue.main.async {
			self.binding.wrappedValue = self.isOn
		}
	}
}
