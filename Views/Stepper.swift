//
//  Stepper.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/13/20.
//

import Foundation

public struct Stepper<Label>: View where Label : View {
	let doubleBinding: Binding<Int>
	let range: ClosedRange<Int>
	let label: Label
	public init<V>(value: Binding<V>, in range: ClosedRange<V>, step: V.Stride, label: () -> Label) where V : Strideable {
		let array = Array(stride(from: range.lowerBound, through: range.upperBound, by: step))
		self.range = ClosedRange(uncheckedBounds: (lower: 0, upper: array.count - 1))
		self.doubleBinding = Binding(get: {
			array.firstIndex(of: value.wrappedValue) ?? 0
		}, set: {
			value.wrappedValue = array[$0]
		})
		self.label = label()
	}
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let label = self.label.__toUIView(enclosingController: enclosingController, environment: environment)
		let stepper = SwiftUIStepper(binding: self.doubleBinding, range: self.range)
		stepper.tintColor = environment.foregroundColor ?? environment.defaultForegroundColor
		stepper.backgroundColor = environment.colorScheme == .dark ? .black : .white
		let vertical = SwiftUIStackView(arrangedSubviews: [stepper], context: .vertical)
		vertical.alignment = .center
        let stackView = SwiftUIStackView(arrangedSubviews: [label, ExpandingView().withContext(.horizontal), vertical], context: .horizontal)
        stackView.spacing = 1
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
        label.isHidden = environment.isLabelsHidden
		return stackView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.label._redraw(view: view.subviews[0], controller: controller, environment: environment)
        view.subviews[0].isHidden = environment.isLabelsHidden
		guard let stepper = view.subviews[2].subviews[0] as? SwiftUIStepper else { return }
		stepper.value = Double(self.doubleBinding.wrappedValue)
		stepper.tintColor = environment.foregroundColor ?? environment.defaultForegroundColor
		stepper.backgroundColor = environment.colorScheme == .dark ? .black : .white
	}
}

class SwiftUIStepper: UIStepper {
	let binding: Binding<Int>
	
	init(binding: Binding<Int>, range: ClosedRange<Int>) {
		self.binding = binding
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.addTarget(self, action: #selector(self.valueChanged), for: .valueChanged)
		self.minimumValue = Double(range.lowerBound)
		self.maximumValue = Double(range.upperBound)
		self.stepValue = 1
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func valueChanged() {
		if self.value > self.maximumValue { print(self.value) }
		self.binding.wrappedValue = Int(self.value.rounded())
	}
}
