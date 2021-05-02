//
//  NavigationLink.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct NavigationLink<Content: View, Destination: View>: View {
	let destination: Destination
	let content: Content
    
    public func _isEqual(toSameType other: NavigationLink<Content, Destination>, environment: EnvironmentValues) -> Bool {
        return content._isEqual(to: other.content, environment: environment)
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        content._hash(into: &hasher, environment: environment)
    }
	
	public init(destination: Destination, content:  () -> Content) {
		self.destination = destination
		self.content = content()
	}
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var newEnvironment = EnvironmentValues(environment)
        weak var controller: UIViewController? = enclosingController
        let buttonControl: NavigationButtonLink
        if !environment.inList {
            newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? .systemBlue
            buttonControl = NavigationButtonLink(view: self.content.__toUIView(enclosingController: enclosingController, environment: newEnvironment), environment: newEnvironment) {
                controller?.navigationController?.pushViewController(SwiftUIInternalController(swiftUIView: self.destination, environment: environment), animated: true)
            }

        } else {
            buttonControl = NavigationButtonLink(view: HStack {
                self.content
                Spacer()
                RightArrow().stroke(lineWidth: 1).foregroundColor(environment.defaultForegroundColor).fixedSize(width: 10, height: 20).padding(edges: .trailing, paddingSpace: 5)
            }.padding().__toUIView(enclosingController: enclosingController, environment: newEnvironment), environment: newEnvironment) {
                controller?.navigationController?.pushViewController(SwiftUIInternalController(swiftUIView: self.destination, environment: environment), animated: true)
            }
        }
				return buttonControl
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        weak var usableController: UIViewController? = controller
		var newEnvironment = EnvironmentValues(environment)
        if !environment.inList {
            newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? .systemBlue
            self.content._redraw(view: view.subviews[0], controller: controller, environment: newEnvironment)
        } else {
            self.content._redraw(view: view.subviews[0].subviews[0], controller: controller, environment: environment)
        }
		guard let navigationButton = view as? NavigationButtonLink else { return }
		navigationButton.onClick = {
            usableController?.navigationController?.pushViewController(SwiftUIInternalController(swiftUIView: self.destination, environment: environment), animated: true)
		}
	}
}

class NavigationButtonLink: ButtonView {
	let environment: EnvironmentValues
	
	init(view: UIView, environment: EnvironmentValues, onClick: @escaping () -> ()) {
		self.environment = environment
		super.init(view: view, onClick: onClick)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func insideList(width: CGFloat) -> (() -> ())? {
		self.isUserInteractionEnabled = false
		return self.onClick
	}
}
