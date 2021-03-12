//
//  SwiftUIController.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import UIKit

internal class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
	var isDismissingSwiping: Bool = false
	let dismissor: Dismissor
	
	init(dismissor: Dismissor) {
		self.dismissor = dismissor
	}
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return Presenter()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return self.dismissor
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		guard isDismissingSwiping else { return nil }
		return animator as? UIViewControllerInteractiveTransitioning
	}
}

class Dismissor: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.35
	}
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let backView = transitionContext.view(forKey: .from) else { return }
		UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
			backView.transform = CGAffineTransform(translationX: 0, y: transitionContext.containerView.frame.height)
		}, completion: {_ in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})
	}
}

class Presenter: NSObject, UIViewControllerAnimatedTransitioning {
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.35
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let forwardView = transitionContext.view(forKey: .to) else { return }
		forwardView.translatesAutoresizingMaskIntoConstraints = false
		let containerView = transitionContext.containerView
		containerView.addSubview(forwardView)
		
		NSLayoutConstraint.activate([
			forwardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			forwardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			forwardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			forwardView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.95)
		])
		
		forwardView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
		
		UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
			forwardView.transform = .identity
		}) {_ in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}
	}
	
	
}

public class SwiftUIController<Content: View>: SwiftUIInternalController<Content> {
	
	lazy var panGesture: UIPanGestureRecognizer = {
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.swipeDown(pan:)))
		self.view.addGestureRecognizer(panGesture)
		return panGesture
	}()
	
	@objc func swipeDown(pan: UIPanGestureRecognizer) {
		guard self.presentingViewController != nil else { return }
		self.transitionDelegate.isDismissingSwiping = true
		let percent = pan.translation(in: self.view).y / self.view.frame.height
		if pan.state == .ended || pan.state == .cancelled {
			if percent > 0.5 {
				self.dismisser.finish()
				self.isShowing?.wrappedValue = false
			} else {
				self.dismisser.cancel()
			}
			self.transitionDelegate.isDismissingSwiping = false
		} else if pan.state == .changed {
			self.dismisser.update(percent)
		} else if pan.state == .began {
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	let dismisser = Dismissor()
	
	lazy var transitionDelegate = TransitionDelegate(dismissor: self.dismisser)
	
	var isShowing: Binding<Bool>? = nil
	
	public init(swiftUIView: Content) {
        super.init(swiftUIView: swiftUIView, environment: EnvironmentValues(UIViewController()))
		self.transitioningDelegate = self.transitionDelegate
		self.panGesture.minimumNumberOfTouches = 1
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

public class SwiftUIInternalController<Content: View>: UIViewController, UpdateDelegate {
	var swiftUIView: Content
	var environment: EnvironmentValues
	
	var actualEnvironment: EnvironmentValues {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = nil
        newEnvironment.isLabelsHidden = false
        newEnvironment.inList = false
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
		let underlyingView = self.swiftUIView.__toUIView(enclosingController: self, environment: self.actualEnvironment)
		showView(underlyingView.asTopLevelView())
    }
	
    public override func viewWillAppear(_ animated: Bool) {
//		self.updateData(with: nil)
	}
	
	func updateData(with animation: Animation?) {
		guard !self.view.subviews.isEmpty else { return }
		var environment = self.actualEnvironment
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
        if underlyingView.insetsLayoutMarginsFromSafeArea {
            NSLayoutConstraint.activate([
                underlyingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                underlyingView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                underlyingView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                underlyingView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
            ])
        } else {
            underlyingView.setupFullConstraints(underlyingView, self.view)
        }
		
		self.view.backgroundColor = self.actualEnvironment.colorScheme == .dark ? .black : .white
	}
    
    deinit {
        self.swiftUIView._reset()
    }

}
