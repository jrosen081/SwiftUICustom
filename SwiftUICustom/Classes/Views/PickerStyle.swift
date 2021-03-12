//
//  PickerStyle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/8/20.
//

import Foundation

public protocol PickerStyle {
    func _updatePicker<Label: View, Selection: Equatable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView) -> _BuildingBlock
    func _redraw<Label: View, Selection: Equatable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView, controller: UIViewController, environment: EnvironmentValues)
}

public struct WheelPickerStyle: PickerStyle {
    public func _updatePicker<Label: View, Selection: Equatable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView) -> _BuildingBlock {
        return UIViewWrapper(view: defaultView)
    }
    
    public func _redraw<Label: View, Selection: Equatable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let expanded = picker.content.expanded()
        let allOptions = expanded.compactMap { $0 as? Taggable & _BuildingBlock}.filter({ $0.taggedValue is Selection})
        let binding: Binding<Int> = Binding(get: {
            return allOptions.firstIndex(where: { $0.taggedValue as? Selection == picker.selectionValue.wrappedValue }) ?? 0
        }, set: {index in
            guard let taggedValue = allOptions[index].taggedValue as? Selection else { return }
            picker.selectionValue.wrappedValue = taggedValue
        })
        guard let actualView = defaultView.subviews.first, let pickerView = actualView.subviews[1] as? SwiftUIPicker else { return }
        pickerView.binding = binding
        pickerView.allOptions = allOptions
        picker.label._redraw(view: actualView.subviews[0], controller: controller, environment: environment)
        actualView.subviews[0].isHidden = environment.isLabelsHidden
    }
}

public typealias DefaultPickerStyle = WheelPickerStyle


struct FormPickerStyle: PickerStyle {
    func _updatePicker<Label: View, Selection: Equatable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView) -> _BuildingBlock {
        let allOptions = picker.content.expanded().compactMap({  $0 as? _BuildingBlock & Taggable })
        let actualOption = allOptions.first(where: { $0.taggedValue as? Selection == picker.selectionValue.wrappedValue }) ?? allOptions.first!
        return NavigationLink(destination: ReferenceList {
            allOptions.map { option in
                HStack {
                    BuildingBlockRepresentable(buildingBlock: option).onTapGestureReloading {
                        guard let value = option.taggedValue as? Selection else { return }
                        picker.selectionValue.wrappedValue = value
                    }
                    Spacer()
                    if option.taggedValue as? Selection == picker.selectionValue.wrappedValue {
                        CheckMark().stroke(lineWidth: 2).fixedSize(width: 15, height: 20).foregroundColor(.systemBlue).padding(edges: .trailing, paddingSpace: 5)
                    }
                }
                
            }
        }, content: {
            HStack {
                picker.label
                Spacer()
                BuildingBlockRepresentable(buildingBlock: actualOption).padding(edges: .trailing, paddingSpace: 5)
            }
        })
    }
    
    func _redraw<Label: View, Selection: Equatable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let allOptions = picker.content.expanded().compactMap({  $0 as? _BuildingBlock & Taggable })
        let actualOption = allOptions.first(where: { $0.taggedValue as? Selection == picker.selectionValue.wrappedValue }) ?? allOptions.first!
        NavigationLink(destination: List {
            allOptions.map { option in
                HStack {
                    BuildingBlockRepresentable(buildingBlock: option).onTapGestureReloading {
                        guard let value = option.taggedValue as? Selection else { return }
                        picker.selectionValue.wrappedValue = value
                    }
                    Spacer()
                    if option.taggedValue as? Selection == picker.selectionValue.wrappedValue {
                        CheckMark().stroke(lineWidth: 2).fixedSize(width: 10, height: 20).foregroundColor(.systemBlue).padding(edges: .trailing, paddingSpace: 5)
                    }
                }
                
            }
        }, content: {
            HStack {
                picker.label
                Spacer()
                BuildingBlockRepresentable(buildingBlock: actualOption).padding(edges: .trailing, paddingSpace: 5)
            }
        })._redraw(view: defaultView, controller: controller, environment: environment)
    }
}


