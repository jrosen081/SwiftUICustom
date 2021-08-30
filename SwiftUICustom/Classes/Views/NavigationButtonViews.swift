//
//  NavigationButtonViews.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/12/20.
//

import Foundation

public struct NavigationButtonViews<Left: View, Right: View, Content: View>: View {
	let leftItem: Left?
	let rightItem: Right?
	let actualView: Content
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        var environment = environment
        environment.labelStyleFunc = IconOnlyLabelStyle().asFunc
        let leftNode = environment.currentStateNode.node(at: 0) ?? type(of: environment.currentStateNode).makeNode(environment: environment, viewController: enclosingController, buildingBlock: self.leftItem ?? EmptyView())
		if let leftItem = self.leftItem {
            var newEnvironment = environment
            newEnvironment.currentStateNode = leftNode
			let buttonItem = UIBarButtonItem(customView: leftItem._toUIView(enclosingController: enclosingController, environment: environment))
            leftNode.uiView = buttonItem.customView!
			enclosingController.navigationItem.leftBarButtonItem = buttonItem
		}
        let rightNode = environment.currentStateNode.node(at: 1) ?? type(of: environment.currentStateNode).makeNode(environment: environment, viewController: enclosingController, buildingBlock: self.rightItem ?? EmptyView())
		if let rightItem = self.rightItem {
            var newEnvironment = environment
            newEnvironment.currentStateNode = rightNode
			let buttonItem = UIBarButtonItem(customView: rightItem._toUIView(enclosingController: enclosingController, environment: environment))
            rightNode.uiView = buttonItem.customView!
			enclosingController.navigationItem.rightBarButtonItem = buttonItem
		}
        let actualViewNode = environment.currentStateNode.node(at: 2) ?? type(of: environment.currentStateNode).makeNode(environment: environment, viewController: enclosingController, buildingBlock: self.actualView)
        var newEnvironment = environment
        newEnvironment.currentStateNode = actualViewNode
		let view = self.actualView._toUIView(enclosingController: enclosingController, environment: newEnvironment)
        actualViewNode.uiView = view
        environment.currentStateNode.childNodes = [leftNode, rightNode, actualViewNode]
        return view
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        var newEnvironment = environment
        newEnvironment.currentStateNode = environment.currentStateNode.childNodes[2]
        newEnvironment.labelStyleFunc = IconOnlyLabelStyle().asFunc
		self.actualView._redraw(view: view, controller: controller, environment: newEnvironment)
		
		if let leftItem = self.leftItem {
            if let barItem = controller.navigationItem.leftBarButtonItem?.customView {
                newEnvironment.currentStateNode = environment.currentStateNode.childNodes[0]
                leftItem._redraw(view: barItem, controller: controller, environment: newEnvironment)
            } else {
                let newNode = type(of: environment.currentStateNode).makeNode(environment: environment, viewController: controller, buildingBlock: leftItem)
                newEnvironment.currentStateNode = newNode
                environment.currentStateNode.childNodes[0] = newNode
                let view = leftItem._toUIView(enclosingController: controller, environment: newEnvironment)
                newNode.uiView = view
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
            }
        } else {
            controller.navigationItem.leftBarButtonItem = nil
        }
		
        if let rightItem = self.rightItem {
            if let barItem = controller.navigationItem.rightBarButtonItem?.customView {
                newEnvironment.currentStateNode = environment.currentStateNode.childNodes[1]
                rightItem._redraw(view: barItem, controller: controller, environment: newEnvironment)
            } else {
                let newNode = type(of: environment.currentStateNode).makeNode(environment: environment, viewController: controller, buildingBlock: rightItem)
                newEnvironment.currentStateNode = newNode
                environment.currentStateNode.childNodes[1] = newNode
                let view = rightItem._toUIView(enclosingController: controller, environment: newEnvironment)
                newNode.uiView = view
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)

            }
        } else {
            controller.navigationItem.rightBarButtonItem = nil
        }
	}
}

public extension View {
	func navigationItems<Right: View>(trailing: Right) -> NavigationButtonViews<Never, Right, Self> {
		return NavigationButtonViews(leftItem: nil, rightItem: trailing, actualView: self)
	}
	
	func navigationItems<Left: View>(leading: Left) -> NavigationButtonViews<Left, Never, Self> {
		return NavigationButtonViews(leftItem: leading, rightItem: nil, actualView: self)
	}
	
	func navigationItems<Left: View, Right: View>(leading: Left, trailing: Right) -> NavigationButtonViews<Left, Right, Self> {
		return NavigationButtonViews(leftItem: leading, rightItem: trailing, actualView: self)
	}
}
