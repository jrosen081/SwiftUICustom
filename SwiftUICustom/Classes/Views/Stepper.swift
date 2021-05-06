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
    
    public func _isEqual(toSameType other: Stepper<Label>, environment: EnvironmentValues) -> Bool {
        doubleBinding.wrappedValue == other.doubleBinding.wrappedValue && range == other.range && label._isEqual(to: other.label, environment: environment)
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        doubleBinding.wrappedValue.hash(into: &hasher)
        range.hash(into: &hasher)
        label._hash(into: &hasher, environment: environment)
    }
    
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
	
    public var body: HStack<TupleView<(Label, Spacer, _StepperView)>> {
        HStack {
            self.label
            Spacer()
            _StepperView(binding: doubleBinding, range: range)
        }
    }
}

public struct _StepperView: UIViewRepresentable {
    public typealias UIViewType = SwiftUIStepper
    @Binding var binding: Int
    let range: ClosedRange<Int>
    
    public func makeUIView(context: Context) -> SwiftUIStepper {
        let stepper = SwiftUIStepper(binding: $binding, range: range)
        let environment = context.environment
        stepper.tintColor = environment.foregroundColor ?? environment.defaultForegroundColor
        stepper.backgroundColor = environment.colorScheme == .dark ? .black : .white
        return stepper
    }
    
    public func updateUIView(_ stepper: SwiftUIStepper, context: Context) {
        let environment = context.environment
        stepper.value = Double(self.binding)
        stepper.tintColor = environment.foregroundColor ?? environment.defaultForegroundColor
        stepper.backgroundColor = environment.colorScheme == .dark ? .black : .white
    }
}

public class SwiftUIStepper: UIStepper {
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
