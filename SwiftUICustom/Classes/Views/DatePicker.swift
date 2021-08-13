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
    
    public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let datePicker = SwiftUIDatePicker(binding: self.binding)
        datePicker.calendar = environment.calendar
        datePicker.minimumDate = self.range.lowerBound
        datePicker.maximumDate = self.range.upperBound
        datePicker.locale = environment.locale
        datePicker.timeZone = environment.timeZone
        environment.currentStateNode.buildingBlock = self.label
        let label = self.label._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = label
        let stack = SwiftUIStackView(arrangedSubviews: [label, datePicker], buildingBlocks: [self.label, UIViewWrapper(view: datePicker)])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 5
        label.isHidden = environment.isLabelsHidden
        return stack
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let picker = view.subviews[1] as? SwiftUIDatePicker
        picker?.minimumDate = self.range.lowerBound
        picker?.maximumDate = self.range.upperBound
        picker?.locale = environment.locale
        picker?.calendar = environment.calendar
        picker?.binding = self.binding
        picker?.timeZone = environment.timeZone
        self.label._redraw(view: view.subviews[0], controller: controller, environment: environment)
        view.subviews[0].isHidden = environment.isLabelsHidden
    }
}

class SwiftUIDatePicker: UIDatePicker {
    
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
