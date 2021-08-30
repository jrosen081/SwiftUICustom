//
//  SwiftUIController.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import UIKit

public class SwiftUIController<Content: View>: SwiftUIInternalController<Content> {
	
	var isShowing: Binding<Bool>? = nil
	
	public init(swiftUIView: Content) {
        super.init(swiftUIView: swiftUIView, environment: EnvironmentValues(UIViewController()), domNode: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

public class SwiftUIInternalController<Content: View>: UIViewController {
    var domNode: DOMNode
    var swiftUIView: Content {
        didSet {
            updateData(with: nil)
        }
    }
	var environment: EnvironmentValues
	
	var actualEnvironment: EnvironmentValues {
		var newEnvironment = environment
        newEnvironment.inList = false
        newEnvironment.cell = nil
		return newEnvironment
	}
    
    var onDeallocate: (() -> Void)?
	
    init(swiftUIView: Content, environment: EnvironmentValues, domNode: DOMNode?) {
		self.swiftUIView = swiftUIView
		self.environment = environment
        self.domNode = domNode ?? DOMNode(environment: environment, viewController: nil, buildingBlock: swiftUIView)
		super.init(nibName: nil, bundle: nil)
        self.domNode.viewController = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func viewDidLoad() {
        super.viewDidLoad()
        var environment = self.actualEnvironment
        environment.currentStateNode = self.domNode
		let underlyingView = self.swiftUIView._toUIView(enclosingController: self, environment: environment)
		showView(underlyingView)
    }
    
    deinit {
        self.onDeallocate?()
        NotificationCenter.default.post(name: swiftUIControllerDeallocatedNotification, object: self)
        print("Bye bye")
    }

	func updateData(with animation: Animation?) {
		guard !self.view.subviews.isEmpty else { return }
		var environment = self.actualEnvironment
        environment.currentStateNode = self.domNode
		environment.currentAnimation = animation
        if self.environment.colorScheme == .dark {
            self.view.backgroundColor = .black
        } else {
            self.view.backgroundColor = .white
        }
		self.swiftUIView._redraw(view: self.view.subviews[0], controller: self, environment: environment)
	}
	
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
        self.environment = self.environment.withUpdates {
            guard !$0.setColorScheme else { return }
            $0.colorScheme = EnvironmentValues(self).colorScheme
        }
		UIView.animate(withDuration: 0.33) {
			self.view.backgroundColor = self.actualEnvironment.colorScheme == .dark ? .black : .white
			self.updateData(with: nil)
		}
	}
	
	func showView(_ underlyingView: UIView) {
		self.view.subviews.forEach { $0.removeFromSuperview() }
		self.view.addSubview(underlyingView)
        NSLayoutConstraint.activate([
            underlyingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            underlyingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            underlyingView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            underlyingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
		
		self.view.backgroundColor = self.actualEnvironment.colorScheme == .dark ? .black : .white
	}
    
    @available(iOS 13.0, *)
    public override func buildMenu(with builder: UIMenuBuilder) {
        
    }
}

let swiftUIControllerDeallocatedNotification = NSNotification.Name("SwiftUIControllerDeallocated")
