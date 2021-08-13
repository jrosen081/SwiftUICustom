//
//  Label.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/19/21.
//

import Foundation

public struct LabelStyleConfiguration {
    public struct Icon: View {
        let icon: _BuildingBlock
        
        public var body: _BuildingBlockRepresentable {
            _BuildingBlockRepresentable(buildingBlock: icon)
        }
    }
    
    public struct Title: View {
        let title: _BuildingBlock
        
        public var body: _BuildingBlockRepresentable {
            _BuildingBlockRepresentable(buildingBlock: title)
        }
    }
    
    public let icon: Icon
    public let title: Title
    
    init<I: View, T: View>(_ i: I, _ t: T) {
        self.icon = Icon(icon: i)
        self.title = Title(title: t)
    }
}

public struct Label<Title, Icon>: View where Title : View, Icon : View {
    private enum Storage {
        case titleIcon(Title, Icon)
        case configuration(LabelStyleConfiguration)
    }
    private let storage: Storage
    @Environment(\.labelStyleFunc) var labelStyle
    
    public init<S>(_ title: S, image name: String) where S : StringProtocol, Title == Text, Icon == Image {
        self = Label(title: { Text(String(title)) }, icon: { Image(name) })
    }
    
    @available(iOS 13, *)
    public init<S>(_ title: S, systemImage name: String) where S : StringProtocol, Title == Text, Icon == Image {
        self = Label(title: { Text(String(title)) }, icon: { Image(systemImage: name) })
    }
    
    public init(@ViewBuilder title: () -> Title, @ViewBuilder icon: () -> Icon) {
        self.storage = .titleIcon(title(), icon())
    }
    
    public init(_ configuration: LabelStyleConfiguration) {
        self.storage = .configuration(configuration)
    }
    
    @ViewBuilder
    public var body: ConditionalContent<_BuildingBlockRepresentable,
                                        HStack<TupleView<
                                                (LabelStyleConfiguration.Icon, LabelStyleConfiguration.Title)>>> {
        switch self.storage {
        case .titleIcon(let title, let icon):
            _BuildingBlockRepresentable(buildingBlock: labelStyle(LabelStyleConfiguration(icon, title)))
        case .configuration(let configuration):
            HStack {
                configuration.icon
                configuration.title
            }
        }
    }
}

public protocol LabelStyle {
    associatedtype Body: View
    typealias Configuration = LabelStyleConfiguration
    func makeBody(configuration: Self.Configuration) -> Self.Body
}

extension LabelStyle {
    var asFunc: (Self.Configuration) -> _BuildingBlock {
        return makeBody(configuration:)
    }
}

public struct IconOnlyLabelStyle: LabelStyle {
    public func makeBody(configuration: Configuration) -> Configuration.Icon {
        configuration.icon
    }
}

public struct TitleOnlyLabelStyle: LabelStyle {
    public func makeBody(configuration: Configuration) -> Configuration.Title {
        configuration.title
    }
}

public struct TitleAndIconLabelStyle: LabelStyle {
    public func makeBody(configuration: Configuration) -> Label<Configuration.Title, Configuration.Icon> {
        Label(configuration)
    }
}

public typealias DefaultLabelStyle = TitleAndIconLabelStyle

public extension View {
    func labelStyle<S: LabelStyle>(_ style: S) -> EnvironmentUpdatingView<Self> {
        self.environment(\.labelStyleFunc, style.asFunc)
    }
}
