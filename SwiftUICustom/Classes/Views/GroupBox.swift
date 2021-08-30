//
//  GroupBox.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/20/21.
//

import Foundation

public struct GroupBoxStyleConfiguration {
    public struct Label: View {
        let buildingBlock: _BuildingBlock
        
        public var body: _BuildingBlockRepresentable {
            _BuildingBlockRepresentable(buildingBlock: buildingBlock)
        }
    }
    
    public struct Content: View {
        let buildingBlock: _BuildingBlock
        
        public var body: _BuildingBlockRepresentable {
            _BuildingBlockRepresentable(buildingBlock: buildingBlock)
        }
    }
    
    public let label: Label
    public let content: Content
    
    init<L: View, C: View>(_ l: L, _ c: C) {
        self.label = Label(buildingBlock: l)
        self.content = Content(buildingBlock: c)
    }
}
public struct GroupBox<Label, Content>: View where Label : View, Content : View {
    private enum Storage {
        case base(Label, Content)
        case configuration(GroupBoxStyleConfiguration)
    }
    
    @Environment(\.boxStyle) var boxStyle
    @Environment(\.colorScheme) var colorScheme
    
    private let storage: Storage
    
    public init(configuration: GroupBoxStyleConfiguration) where Label == GroupBoxStyleConfiguration.Label, Content == GroupBoxStyleConfiguration.Content {
        self.storage = .configuration(configuration)
    }
    
    public init(@ViewBuilder content: () -> Content) where Label == EmptyView {
        self = GroupBox(content: content, label: { EmptyView() })
    }
    
    public init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        self.storage = .base(label(), content())
    }
    
    @ViewBuilder
    public var body: ConditionalContent<_BuildingBlockRepresentable, ClipShapedView<RoundedRectangle, BackgroundColorView<PaddingView<VStack<TupleView<(HStack<TupleView<(GroupBoxStyleConfiguration.Label, Spacer)>>, GroupBoxStyleConfiguration.Content)>>>>>> {
        switch storage {
        case .base(let label, let content):
            _BuildingBlockRepresentable(buildingBlock: boxStyle.configurationBuilder(GroupBoxStyleConfiguration(label, content)))
        case .configuration(let configuration):
            VStack(alignment: .leading) {
                HStack {
                    configuration.label
                    Spacer()
                }
                configuration.content
            }.padding()
            .background(colorScheme == .dark ? Color(uiColor: .darkGray) : Color(uiColor: .lightGray))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}


public protocol GroupBoxStyle {
    associatedtype Body: View
    typealias Configuration = GroupBoxStyleConfiguration
    
    func makeBody(configuration: Configuration) -> Body
}

struct BoxStyle {
    let configurationBuilder: (GroupBoxStyleConfiguration) -> _BuildingBlock
    init<Style: GroupBoxStyle>(style: Style) {
        configurationBuilder = style.makeBody(configuration:)
    }
}

public struct DefaultGroupBoxStyle: GroupBoxStyle {
    public func makeBody(configuration: Configuration) -> GroupBox<GroupBoxStyleConfiguration.Label, GroupBoxStyleConfiguration.Content> {
        GroupBox(configuration: configuration)
    }
}

public extension View {
    func groupBoxStyle<S: GroupBoxStyle>(_ style: S) -> EnvironmentUpdatingView<Self> {
        EnvironmentUpdatingView(content: self) { $0.boxStyle = BoxStyle(style: style) }
    }
}
