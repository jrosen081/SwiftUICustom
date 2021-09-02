//
//  ColorPicker.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/12/21.
//

import Foundation

@available(iOS 14, *)
public struct ColorPicker<Label>: View where Label : View {
    let label: Label
    @Binding var color: Color
    let supportsAlpha: Bool
    @Environment(\.isLabelsHidden) var labelsHidden
    @State private var showingController: Bool = false
    
    public init(selection: Binding<Color>, supportsOpacity: Bool = true, @ViewBuilder label: () -> Label) {
        self.label = label()
        self._color = selection
        self.supportsAlpha = supportsOpacity
    }
    
    public init<S: StringProtocol>(_ titleKey: S, selection: Binding<Color>, supportsOpacity: Bool = true) where Label == Text {
        self = ColorPicker(selection: selection, supportsOpacity: supportsOpacity, label: { Text(String(titleKey)) })
    }
    
    public var body: some View {
        HStack {
            if !labelsHidden {
                self.label
                Spacer()
            }
            Button(action: {
                self.showingController = true
            }) {
                color.clipShape(Circle()).frame(width: 100, height: 100)
            }.popover(isShowing: $showingController) {
                UIColorPickerRepresentable(color: $color, supportsAlpha: supportsAlpha)
            }
        }
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}

@available(iOS 14, *)
public struct UIColorPickerRepresentable: UIViewControllerRepresentable {
    @Binding var color: Color
    let supportsAlpha: Bool
    public typealias UIViewControllerType = UIColorPickerViewController
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(color: $color)
    }
    
    public func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let controller = UIColorPickerViewController()
        controller.selectedColor = color.uiColor
        controller.supportsAlpha = supportsAlpha
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ controller: UIColorPickerViewController, context: Context) {
        controller.selectedColor = color.uiColor
        controller.supportsAlpha = supportsAlpha
    }
    
    public class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        @Binding var color: Color
        
        init(color: Binding<Color>) {
            self._color = color
        }
        
        public func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            self.color = Color(uiColor: viewController.selectedColor)
        }
    }
}
