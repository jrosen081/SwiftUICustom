//
//  PickerStyle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/8/20.
//

import Foundation

public protocol PickerStyle {
    func _updatePicker<Label: View, Selection: Hashable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView) -> _BuildingBlock
    func _redraw<Label: View, Selection: Hashable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView, controller: UIViewController, environment: EnvironmentValues)
}

public struct WheelPickerStyle: PickerStyle {
    public func _updatePicker<Label: View, Selection: Hashable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView) -> _BuildingBlock {
        return UIViewWrapper(view: defaultView)
    }
    
    public func _redraw<Label: View, Selection: Hashable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView, controller: UIViewController, environment: EnvironmentValues) {
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


private struct SelectableView<V: View>: View {
    let child: V
    let isSelected: Bool
    let select: () -> Void
    @Environment(\.cell) var cell
    
    var body: OnChangeView<Bool, OnAppearView<OnTapGestureView<V>>> {
        child.onTapGesture(select).onAppear {
            cell?.accessoryType = isSelected ? .checkmark : .none
        }.onChange(of: isSelected) { isSelected in
            cell?.accessoryType = isSelected ? .checkmark : .none
        }
    }
}

private struct SelectableViewList<Selection: Hashable>: View {
    @Binding var selection: Selection
    let allViews: [_BuildingBlock & Taggable]
    
    var body: List<ForEach<_BuildingBlock & Taggable, AnyHashable, SelectableView<_BuildingBlockRepresentable>>> {
        List {
            ForEach(allViews, id: \.taggedValue) { view in
                SelectableView(child: _BuildingBlockRepresentable(buildingBlock: view), isSelected: AnyHashable(selection) == view.taggedValue) {
                    if let value = view.taggedValue.base as? Selection {
                        selection = value
                    }
                }
            }
        }
    }
}

struct FormPickerStyle: PickerStyle {
    func _updatePicker<Label: View, Selection: Hashable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView) -> _BuildingBlock {
        let allOptions = picker.content.expanded().compactMap({  $0 as? _BuildingBlock & Taggable })
        let actualOption = allOptions.first(where: { $0.taggedValue as? Selection == picker.selectionValue.wrappedValue }) ?? allOptions.first!
        return NavigationLink(destination: SelectableViewList(selection: picker.selectionValue, allViews: allOptions), content: {
            HStack {
                picker.label
                Spacer()
                _BuildingBlockRepresentable(buildingBlock: actualOption).padding(edges: .trailing, paddingSpace: 5)
            }
        })
    }
    
    func _redraw<Label: View, Selection: Hashable, Content: View>(picker: Picker<Label, Selection, Content>, defaultView: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let allOptions = picker.content.expanded().compactMap({  $0 as? _BuildingBlock & Taggable })
        let actualOption = allOptions.first(where: { $0.taggedValue as? Selection == picker.selectionValue.wrappedValue }) ?? allOptions.first!
        NavigationLink(destination: SelectableViewList(selection: picker.selectionValue, allViews: allOptions), content: {
            HStack {
                picker.label
                Spacer()
                _BuildingBlockRepresentable(buildingBlock: actualOption).padding(edges: .trailing, paddingSpace: 5)
            }
        })._redraw(view: defaultView, controller: controller, environment: environment)
    }
}


