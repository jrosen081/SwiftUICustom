//
//  PickerStyle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/8/20.
//

import Foundation

public protocol PickerStyle {
    func _makePickerView<Label: View, Selection: Hashable, Content: View>(picker: Picker<Label, Selection, Content>) -> _BuildingBlockRepresentable
}

public struct WheelPickerStyle: PickerStyle {
    public func _makePickerView<Label, Selection, Content>(picker: Picker<Label, Selection, Content>) -> _BuildingBlockRepresentable where Label : View, Selection : Hashable, Content : View {
        let value = HStack {
            if !picker.environment.isLabelsHidden {
                picker.label
                Spacer()
            }
            UIPickerRepresentable(content: picker.content, selectionValue: picker.selectionValue)
        }
        return _BuildingBlockRepresentable(buildingBlock: value)
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
    
    func _makePickerView<Label, Selection, Content>(picker: Picker<Label, Selection, Content>) -> _BuildingBlockRepresentable where Label : View, Selection : Hashable, Content : View {
        let allOptions = picker.content._makeSequence(currentNode: picker.environment.currentStateNode)
            .expanded(node: picker.environment.currentStateNode)
            .map(\.0.buildingBlock)
            .compactMap({  $0 as? _BuildingBlock & Taggable })
        let actualOption = allOptions.first(where: { $0.taggedValue as? Selection == picker.selectionValue.wrappedValue }) ?? allOptions.first!
        let actual =
            HStack {
                if !picker.environment.isLabelsHidden {
                    picker.label
                    Spacer()
                }
                NavigationLink(destination: SelectableViewList(selection: picker.selectionValue, allViews: allOptions), content: {
                    HStack {
                        picker.label
                        Spacer()
                        _BuildingBlockRepresentable(buildingBlock: actualOption).padding(edges: .trailing, paddingSpace: 5)
                    }
                })
            }
        return _BuildingBlockRepresentable(buildingBlock: actual)
    }
}

@available(iOS 14, *)
public struct MenuPickerStyle: PickerStyle {
    public func _makePickerView<Label, Selection, Content>(picker: Picker<Label, Selection, Content>) -> _BuildingBlockRepresentable where Label : View, Selection : Hashable, Content : View {
        let menu = Menu({ picker }, label: { picker.label })
        return _BuildingBlockRepresentable(buildingBlock: menu)
    }
}


