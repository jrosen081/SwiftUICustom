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
	
	public var body: HStack<TupleView<(Label, Spacer, SliderRepresentable)>> {
        HStack {
            self.labelCreator
            Spacer()
            SliderRepresentable(binding: binding, range: range)
        }
	}

    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
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

public struct SliderRepresentable: UIViewRepresentable {
    @Binding var binding: Float
    let range: ClosedRange<Float>
    public typealias UIViewType = _SwiftUISlider
    
    public func makeUIView(context: Context) -> _SwiftUISlider {
        let slider = _SwiftUISlider(binding: $binding, closedRange: range)
        let environment = context.environment
        slider.tintColor = environment.foregroundColor
        return slider
    }
    
    public func updateUIView(_ view: _SwiftUISlider, context: Context) {
        let environment = context.environment
        view.tintColor = environment.foregroundColor
        view.maximumValue = self.range.upperBound
        view.minimumValue = self.range.lowerBound
        view.value = binding
    }
}

public class _SwiftUISlider: UISlider {
	let binding: Binding<Float>
	
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
