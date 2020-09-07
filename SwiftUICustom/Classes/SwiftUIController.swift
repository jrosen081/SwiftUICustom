//
//  SwiftUIController.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import UIKit

public class SwiftUIController: UINavigationController {
	
	public init<Content: View>(swiftUIView: Content) {
		super.init(nibName: nil, bundle: nil)
		self.viewControllers = [SwiftUIInternalController(swiftUIView: swiftUIView, environment: EnvironmentValues())]
		self.isNavigationBarHidden = true
		self.navigationBar.prefersLargeTitles = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

internal class SwiftUIInternalController<Content: View>: UIViewController, UpdateDelegate {
	let swiftUIView: Content
	let environment: EnvironmentValues
	
	var actualEnvironment: EnvironmentValues {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = nil
		if #available(iOS 12.0, *) {
			newEnvironment.colorScheme = self.traitCollection.userInterfaceStyle == .dark ? .dark : .light
		} else {
			newEnvironment.colorScheme = .light
		}
		return newEnvironment
	}
	
	public init(swiftUIView: Content, environment: EnvironmentValues) {
		self.swiftUIView = swiftUIView
		self.environment = environment
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func viewDidLoad() {
        super.viewDidLoad()
		let underlyingView = self.swiftUIView.toUIView(enclosingController: self, environment: self.actualEnvironment)
		showView(underlyingView.asTopLevelView())
    }
	
	func updateData() {
		self.swiftUIView.redraw(view: self.view.subviews[0], controller: self, environment: self.actualEnvironment)
	}
	
	func showView(_ underlyingView: UIView) {
		self.view.subviews.forEach { $0.removeFromSuperview() }
		self.view.addSubview(underlyingView)
		NSLayoutConstraint.activate([
			underlyingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
			underlyingView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			underlyingView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
			underlyingView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
		])
		self.view.backgroundColor = self.actualEnvironment.colorScheme == .dark ? .black : .white
	}

}
