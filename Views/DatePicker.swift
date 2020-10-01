//
//  DatePicker.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/30/20.
//

import Foundation

public struct DatePicker<Label: View>: View {
    let label: Label
    let components: UIDatePicker.Mode
    let range: ClosedRange<Date>
    let binding: Binding<Date>
    
    public init<S>(_ title: S, selection: Binding<Date>, displayedComponents: UIDatePicker.Mode = .dateAndTime) where S : StringProtocol, Label == Text {
        self = DatePicker<Label>(selection: selection, in: Date.distantPast...Date.distantFuture, displayedComponents: displayedComponents, label: {
            Text(String(title))
        })
    }
    
    public init(selection: Binding<Date>, in range: ClosedRange<Date>, displayedComponents: UIDatePicker.Mode, label: () -> Label) {
        self.label = label()
        self.components = displayedComponents
        self.range = range
        self.binding = selection
    }
    
    public var body: Self {
        return self
    }
    
    public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let datePicker = SwiftUIDatePicker(binding: self.binding)
        datePicker.minimumDate = self.range.lowerBound
        datePicker.maximumDate = self.range.upperBound
        let label = self.label.__toUIView(enclosingController: enclosingController, environment: environment)
        let stack = SwiftUIStackView(arrangedSubviews: [label, datePicker], context: .horizontal)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 5
        label.isHidden = environment.isLabelsHidden
        return stack
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let picker = view.subviews[1] as? SwiftUIDatePicker
        picker?.minimumDate = self.range.lowerBound
        picker?.maximumDate = self.range.upperBound
        picker?.binding = self.binding
        self.label._redraw(view: view.subviews[0], controller: controller, environment: environment)
        view.subviews[0].isHidden = environment.isLabelsHidden
    }
}

class SwiftUIDatePicker: UIDatePicker {
    
    override func willExpand(in context: ExpandingContext) -> Bool {
        return context == .horizontal
    }
    
    var binding: Binding<Date> {
        didSet {
            self.date = binding.wrappedValue
        }
    }
    
    init(binding: Binding<Date>) {
        self.binding = binding
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: 280).isActive = true
    }
    
    @objc func dateChanged() {
        self.binding.wrappedValue = self.date
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
