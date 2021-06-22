//
//  NavigationTopView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct NavigationTopView<Content: View>: View {
	let content: Content
	let title: String
	let prefersLarge: Bool
	
	public var body: Content {
		return self.content
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		enclosingController.navigationItem.title = self.title
		if let navigationController = enclosingController.navigationController, let index = navigationController.viewControllers.firstIndex(of: enclosingController) {
            enclosingController.navigationItem.largeTitleDisplayMode = index == 0 && self.prefersLarge ? .automatic : .never
		}
		return self.content._toUIView(enclosingController: enclosingController, environment: environment)
	}
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        controller.navigationItem.title = self.title
        if let navigationController = controller.navigationController, let index = navigationController.viewControllers.firstIndex(of: controller) {
            controller.navigationItem.largeTitleDisplayMode = index == 0 && self.prefersLarge ? .automatic : .never
        }
        self.content._redraw(view: view, controller: controller, environment: environment)
    }
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        content._requestedSize(within: size, environment: environment)
    }
}

public extension View {
	func navigationTitle(_ string: String, prefersLarge: Bool = true) -> NavigationTopView<Self> {
		return NavigationTopView(content: self, title: string, prefersLarge: prefersLarge)
	}
}
