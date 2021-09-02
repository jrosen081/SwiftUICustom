//
//  ProgressView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/30/21.
//

import Foundation

public struct ProgressView<Label: View, CurrentValueLabel: View>: View {
    let progress: Float?
    let label: Label
    let currentValueLabel: CurrentValueLabel
    
    public init(@ViewBuilder label: () -> Label) where CurrentValueLabel == EmptyView {
        self.progress = nil
        self.currentValueLabel = EmptyView()
        self.label = label()
    }
    
    public init() where Label == EmptyView, CurrentValueLabel == EmptyView {
        self = ProgressView(label: { EmptyView() })
    }
    
    public init<V>(value: V?, total: V = 1.0) where Label == EmptyView, CurrentValueLabel == EmptyView, V : BinaryFloatingPoint {
        self = ProgressView(value: value, total: total, label: { EmptyView() }, currentValueLabel: { EmptyView() })
    }
    
    public init<V>(value: V?, total: V = 1.0, @ViewBuilder label: () -> Label, @ViewBuilder currentValueLabel: () -> CurrentValueLabel) where V : BinaryFloatingPoint {
        self.label = label()
        self.currentValueLabel = currentValueLabel()
        self.progress = value.map { $0 / total }.map(Float.init)
    }
    
    public var body: VStack<TupleView<(Label, ConditionalContent<UIProgressRepresentable, ActivityIndicator>, CurrentValueLabel)>> {
        VStack {
            self.label
            if let progress = progress {
                UIProgressRepresentable(progress: progress)
            } else {
                ActivityIndicator()
            }
            self.currentValueLabel
        }
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}

public struct ActivityIndicator: UIViewRepresentable {
    public typealias UIViewType = UIActivityIndicatorView
    
    public func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }
    
    public func updateUIView(_ view: UIActivityIndicatorView, context: Context) {
        // Do nothing
    }
}

public struct UIProgressRepresentable: UIViewRepresentable {
    public typealias UIViewType = UIProgressView
    let progress: Float
    public func makeUIView(context: Context) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = progress
        return progressView
    }
    
    public func updateUIView(_ view: UIProgressView, context: Context) {
        view.progress = progress
    }
}
