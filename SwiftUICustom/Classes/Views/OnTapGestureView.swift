//
//  OnTapGestureView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/15/20.
//

import Foundation

public struct OnTapGestureView<Content: View>: View {
    public func _isEqual(toSameType other: OnTapGestureView<Content>, environment: EnvironmentValues) -> Bool {
        content._isEqual(to: other.content, environment: environment) && reload == other.reload
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        content._hash(into: &hasher, environment: environment)
        reload.hash(into: &hasher)
    }
    
	let content: Content
	let onClick: () -> ()
    let reload: Bool
    
    func getActualOnClick(enclosingController: UIViewController) -> () -> () {
        return {
            onClick()
            if reload, let delegate = enclosingController as? UpdateDelegate {
                delegate.updateData(with: nil)
            }
        }
    }
	
    public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let view = content.__toUIView(enclosingController: enclosingController, environment: environment)
		let buttonView = ButtonView(view: view, onClick: getActualOnClick(enclosingController: enclosingController))
		buttonView.alphaToChangeTo = 1
		return buttonView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let button = view as? ButtonView else { return }
        button.onClick = getActualOnClick(enclosingController: controller)
		self.content._redraw(view: view.subviews[0], controller: controller, environment: environment)
	}
}

extension View {
    func onTapGestureReloading(_ onclick: @escaping () -> ()) -> OnTapGestureView<Self> {
        return OnTapGestureView(content: self, onClick: onclick, reload: true)
    }
}

public extension View {
	func onTapGesture(_ onClick: @escaping () -> ()) -> OnTapGestureView<Self> {
        return OnTapGestureView(content: self, onClick: onClick, reload: false)
	}
}
