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
		if let leftItem = self.leftItem {
			let buttonItem = UIBarButtonItem(customView: leftItem._toUIView(enclosingController: enclosingController, environment: environment))
			enclosingController.navigationItem.leftBarButtonItem = buttonItem
		}
		
		if let rightItem = self.rightItem {
			let buttonItem = UIBarButtonItem(customView: rightItem._toUIView(enclosingController: enclosingController, environment: environment))
			enclosingController.navigationItem.rightBarButtonItem = buttonItem
		}
		
		return self.actualView._toUIView(enclosingController: enclosingController, environment: environment)
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.actualView._redraw(view: view, controller: controller, environment: environment)
		
		if let leftItem = self.leftItem, let barItem = controller.navigationItem.leftBarButtonItem?.customView {
			leftItem._redraw(view: barItem, controller: controller, environment: environment)
		}
		
		if let rightItem = self.rightItem, let barItem = controller.navigationItem.rightBarButtonItem?.customView {
			rightItem._redraw(view: barItem, controller: controller, environment: environment)
		}
	}
    
    public func _isEqual(toSameType other: NavigationButtonViews<Left, Right, Content>, environment: EnvironmentValues) -> Bool {
        guard (leftItem == nil) == (other.leftItem == nil) && (rightItem == nil) == (other.rightItem == nil) else { return false }
        if let leftItem = leftItem, let otherLeft = other.leftItem {
            guard leftItem._isEqual(to: otherLeft, environment: environment) else { return false }
        }
        
        if let rightItem = rightItem, let otherRight = other.rightItem {
            guard rightItem._isEqual(to: otherRight, environment: environment) else { return false }
        }
        return actualView._isEqual(to: other.actualView, environment: environment)
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        actualView._hash(into: &hasher, environment: environment)
        leftItem?._hash(into: &hasher, environment: environment)
        rightItem?._hash(into: &hasher, environment: environment)
    }
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        actualView._requestedSize(within: size, environment: environment)
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
