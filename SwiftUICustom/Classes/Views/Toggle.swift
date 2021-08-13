//
//  Toggle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/9/20.
//

import Foundation

public struct Toggle<Label: View>: View {
	let creation: Label
	let isOn: Binding<Bool>
    @Environment(\.isLabelsHidden) var labelsHidden
    
	public init(isOn: Binding<Bool>, @ViewBuilder creation: () -> Label) {
		self.creation = creation()
		self.isOn = isOn
	}
	
	public var body: HStack<TupleView<(ConditionalContent<Label, EmptyView>, Spacer, SwitchRepresentable)>> {
        HStack {
            if !labelsHidden {
                creation
            }
            Spacer()
            SwitchRepresentable(isOn: isOn)
        }
	}
}

public struct SwitchRepresentable: UIViewRepresentable {
    @Binding var isOn: Bool
    public typealias UIViewType = SwiftUISwitch
    
    public func makeUIView(context: Context) -> SwiftUISwitch {
        let toggle = SwiftUISwitch(binding: $isOn)
        toggle.onTintColor = context.environment.foregroundColor ?? .systemGreen
        return toggle
    }
    
    public func updateUIView(_ view: SwiftUISwitch, context: Context) {
        view.onTintColor = context.environment.foregroundColor ?? .systemGreen
        view.setOn(isOn, animated: true)
    }
}

public class SwiftUISwitch: UISwitch {
	let binding: Binding<Bool>
	
	init(binding: Binding<Bool>) {
		self.binding = binding
		super.init(frame: .zero)
		self.isOn = binding.wrappedValue
		self.addTarget(self, action: #selector(self.changedValue), for: .valueChanged)
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func changedValue() {
		guard self.binding.wrappedValue != self.isOn else { return }
        self.binding.wrappedValue = self.isOn
	}
}
