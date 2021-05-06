//
//  Slider.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/13/20.
//

import Foundation

public struct Slider<Label, ValueLabel>: View where Label : View, ValueLabel : View {
	let binding: Binding<Float>
	let range: ClosedRange<Float>
	let stride: Float
	let labelCreator: Label
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        range.hash(into: &hasher)
        stride.hash(into: &hasher)
        labelCreator._hash(into: &hasher, environment: environment)
        binding.wrappedValue.hash(into: &hasher)
    }
    
    public func _isEqual(toSameType other: Slider<Label, ValueLabel>, environment: EnvironmentValues) -> Bool {
        range == other.range && stride == other.stride && labelCreator._isEqual(to: other.labelCreator, environment: environment) && binding.wrappedValue == other.binding.wrappedValue
    }
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        let width = size.width
        return CGSize(width: width, height: max(labelCreator._requestedSize(within: size, environment: environment).height, UISlider().intrinsicContentSize.height))
    }
	
	public init<V>(value: Binding<V>, in bounds: ClosedRange<V> = 0...1, label: () -> Label) where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint, ValueLabel == EmptyView {
		self.range = ClosedRange(uncheckedBounds: (lower: Float(bounds.lowerBound), upper: Float(bounds.upperBound)))
		self.stride = 1
		self.binding = Binding<Float>.createBinding(value: value, step: 1, closedRange: bounds)
		self.labelCreator = label()
	}
	
	public init<V>(value: Binding<V>, in bounds: ClosedRange<V> = 0...1, step: V.Stride, label: () -> Label) where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint, ValueLabel == EmptyView {
		self.range = ClosedRange(uncheckedBounds: (lower: Float(bounds.lowerBound), upper: Float(bounds.upperBound)))
		self.stride = Float(step)
		self.binding = Binding<Float>.createBinding(value: value, step: step, closedRange: bounds)
		self.labelCreator = label()
	}
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let slider = SwiftUISlider(binding: self.binding, closedRange: self.range)
		slider.tintColor = environment.foregroundColor
		let label = self.labelCreator._toUIView(enclosingController: enclosingController, environment: environment)
        let horizontalStack = SwiftUIStackView(arrangedSubviews: [label, slider], context: .horizontal, buildingBlocks: [self.labelCreator, UIViewWrapper(view: slider)])
		horizontalStack.axis = .horizontal
		horizontalStack.translatesAutoresizingMaskIntoConstraints = false
		horizontalStack.spacing = 5
        label.isHidden = environment.isLabelsHidden
		return horizontalStack
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.labelCreator._redraw(view: view.subviews[0], controller: controller, environment: environment)
        view.subviews[0].isHidden = environment.isLabelsHidden
		guard let slider = view.subviews[1] as? UISlider else { return }
		slider.tintColor = environment.foregroundColor
	}
}

extension Binding where T: BinaryFloatingPoint {
	static func createBinding<V: BinaryFloatingPoint>(value: Binding<V>, step: V.Stride, closedRange: ClosedRange<V>) -> Binding<T> where V.Stride : BinaryFloatingPoint {
		Binding(get: {
			return T(value.wrappedValue)
		}, set: { newValue in
			let values = Swift.stride(from: closedRange.lowerBound, through: closedRange.upperBound, by: step)
			guard let goodValue = newValue.roundToClosest(values: values) else { return }
			value.wrappedValue = goodValue
		})
	}
}

extension BinaryFloatingPoint {
	func roundToClosest<T: BinaryFloatingPoint>(values: StrideThrough<T>) -> T? where T.Stride : BinaryFloatingPoint {
		return values.map { ($0, abs(Self($0) - self)) }
			.min(by: { $0.1 < $1.1 })?.0
	}
}

class SwiftUISlider: UISlider {
	let binding: Binding<Float>
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIView.layoutFittingExpandedSize.width, height: super.intrinsicContentSize.height)
	}
	
	override func willExpand(in context: ExpandingContext) -> Bool {
		return context == .horizontal
	}
	
	init(binding: Binding<Float>, closedRange: ClosedRange<Float>) {
		self.binding = binding
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.addTarget(self, action: #selector(self.valueChanged), for: .valueChanged)
		self.minimumValue = closedRange.lowerBound
		self.maximumValue = closedRange.upperBound
	}
	
	@objc func valueChanged() {
		binding.wrappedValue = self.value
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
