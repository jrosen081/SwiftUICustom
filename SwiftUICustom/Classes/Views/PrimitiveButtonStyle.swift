//
//  PrimitiveButtonStyle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/13/20.
//

import Foundation

public protocol _PrimitiveButtonStyle {
    func _makeBody(configuration: Self.Configuration) -> _BuildingBlock
    typealias Configuration = PrimitiveButtonStyleConfiguration
}

public protocol PrimitiveButtonStyle: _PrimitiveButtonStyle {
    func makeBody(configuration: Self.Configuration) -> Self.Body
    associatedtype Body : View
}

public extension PrimitiveButtonStyle {
    func _makeBody(configuration: PrimitiveButtonStyleConfiguration) -> _BuildingBlock {
        return self.makeBody(configuration: configuration)
    }
}

public struct PrimitiveButtonStyleConfiguration {
    public let label: Label
    let onClick: () -> ()
    let isNavigationLink: Bool
    
    public func trigger() {
        onClick()
    }
    
    public struct Label: View {
        let buildingBlock: _BuildingBlock
        
        public var body: Self {
            return self
        }
        
        public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
            return self.buildingBlock._toUIView(enclosingController: enclosingController, environment: environment)
        }
        
        public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
            self.buildingBlock._redraw(view: view, controller: controller, environment: environment)
        }
        
        public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
            buildingBlock._requestedSize(within: size, environment: environment)
        }
    }
}

public struct BorderlessButtonStyle: PrimitiveButtonStyle {
    public func makeBody(configuration: Configuration) -> Configuration.Label {
        return configuration.label
    }
}

public typealias DefaultButtonStyle = BorderlessButtonStyle

struct FormButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> PaddingView<HStack<TupleView<(Configuration.Label, Spacer)>>> {
        return HStack {
            configuration.label
            Spacer()
        }.padding()
    }
}


