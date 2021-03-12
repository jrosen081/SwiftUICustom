//
//  Picker.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/29/20.
//

import Foundation

public struct Picker<Label, SelectionValue, Content>: View where Label : View, SelectionValue : Hashable, Content : View {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.label == rhs.label && lhs.content == rhs.content && lhs.selectionValue.wrappedValue == rhs.selectionValue.wrappedValue
    }
    
    public func hash(into hasher: inout Hasher) {
        self.label.hash(into: &hasher)
        self.selectionValue.wrappedValue.hash(into: &hasher)
        self.content.hash(into: &hasher)
    }
    
    let label: Label
    let content: Content
    let selectionValue: Binding<SelectionValue>
    
    public init<S>(_ title: S, selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) where S : StringProtocol, Label == Text {
        self.label = Text(String(title))
        self.selectionValue = selection
        self.content = content()
    }
    
    public var body: Self {
        return self
    }
    
    public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let expanded = self.content.expanded()
        let allOptions = expanded.compactMap { $0 as? Taggable & _BuildingBlock}.filter({ $0.taggedValue is SelectionValue})
        let binding: Binding<Int> = Binding(get: {
            return allOptions.firstIndex(where: { $0.taggedValue as? SelectionValue == self.selectionValue.wrappedValue }) ?? 0
        }, set: {index in
            guard let taggedValue = allOptions[index].taggedValue as? SelectionValue else { return }
            self.selectionValue.wrappedValue = taggedValue
        })
        let picker = SwiftUIPicker(binding: binding, stringOptions: allOptions)
        picker.environment = environment
        picker.allOptions = allOptions
        let label = self.label.__toUIView(enclosingController: enclosingController, environment: environment)
        let stackView = SwiftUIStackView(arrangedSubviews: [label, picker], context: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 5
        label.isHidden = environment.isLabelsHidden
        return environment.pickerStyle._updatePicker(picker: self, defaultView: stackView).__toUIView(enclosingController: enclosingController, environment: environment)
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        environment.pickerStyle._redraw(picker: self, defaultView: view, controller: controller, environment: environment)
    }
}

class SwiftUIPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    var environment = EnvironmentValues()
    var binding: Binding<Int>
    var allOptions: [_BuildingBlock] {
        didSet {
            self.reloadAllComponents()
            self.selectRow(binding.wrappedValue, inComponent: 0, animated: true)
        }
    }
    
    init(binding: Binding<Int>, stringOptions: [_BuildingBlock]) {
        self.binding = binding
        self.allOptions = stringOptions
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.dataSource = self
        self.delegate = self
        self.reloadAllComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = self.allOptions[row].__toUIView(enclosingController: UIViewController(), environment: self.environment)
        let expandingView = ExpandingView()
        expandingView.context = [.horizontal]
        let expandingView2 = ExpandingView()
        expandingView2.context = [.horizontal]
        return SwiftUIStackView(arrangedSubviews: [expandingView, view, expandingView2], context: .horizontal)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.binding.wrappedValue = row
    }
}