//
//  EnvironmentUpdatingView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct EnvironmentUpdatingView<Content: View>: View {
	let content: Content
	let updates: (inout EnvironmentValues) -> ()
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var updates = environment.withUpdates(self.updates)
        let newNode = DOMNode(environment: updates, viewController: enclosingController, buildingBlock: self.content)
        environment.currentStateNode.addChild(node: newNode, index: 0)
        updates.currentStateNode = newNode
		let view = self.content._toUIView(enclosingController: enclosingController, environment: updates)
        newNode.uiView = view
        return view
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let node = environment.currentStateNode.childNodes[0]
        var newEnvironment = environment.withUpdates(self.updates)
        node.environment = newEnvironment
        newEnvironment.currentStateNode = node
		self.content._redraw(view: view, controller: controller, environment: newEnvironment)
	}
}

public extension View {
	func font(_ font: UIFont) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0.font = font
		})
	}
	
	func lineLimit(_ limit: Int?) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0.lineLimit = limit
		})
	}
	
	func lineSpacing(_ spacing: CGFloat) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0.lineSpacing = spacing
		})
	}
	
	func multilineTextAlignment(_ alignment: NSTextAlignment) -> EnvironmentUpdatingView<Self> {
		 return EnvironmentUpdatingView(content: self, updates: {
			$0.multilineTextAlignment = alignment
		 })
	}

	func minimumScaleFactor(_ scale: CGFloat) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
		   $0.minimumScaleFactor = scale
		})
	}
	
	func allowsTightening(_ tightening: Bool) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
		   $0.allowsTightening = tightening
		})
	}
	
	func textContentType(_ textContentType: UITextContentType?) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0.textContentType = textContentType
		})
	}

	func environmentObject<Object: ObservableObject>(_ object: Object) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0[EnvironmentObjectGetter<Object>.self] = object
		})
	}
	
	func environment<Object>(_ keyPath: WritableKeyPath<EnvironmentValues, Object>, _ object: Object) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: { (environment: inout EnvironmentValues) in
			environment[keyPath: keyPath] = object
		})
	}
	
	func animation(_ animation: Animation) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			$0.currentAnimation = animation
		})
	}
	
	func transition(_ transition: AnyTransition) -> EnvironmentUpdatingView<Self> {
		return EnvironmentUpdatingView(content: self, updates: {
			// Only override it if there is an animation
			$0.currentTransition = transition
		})
	}
    
    
    func keyboardType(_ type: UIKeyboardType) -> EnvironmentUpdatingView<Self> {
        return EnvironmentUpdatingView(content: self, updates: {
            $0.keyboardType = type
        })
    }
    
    func labelsHidden() -> EnvironmentUpdatingView<Self> {
        return EnvironmentUpdatingView(content: self, updates: {
            $0.isLabelsHidden = true
        })
    }
    
    func listStyle(_ style: ListStyle) -> EnvironmentUpdatingView<Self> {
        return EnvironmentUpdatingView(content: self, updates: {
            $0.listStyle = style
        })
    }
    
    func pickerStyle(_ style: PickerStyle) -> EnvironmentUpdatingView<Self> {
        return EnvironmentUpdatingView(content: self, updates: {
            $0.pickerStyle = style
        })
    }
    
    func textFieldStyle(_ style: TextFieldStyle) -> EnvironmentUpdatingView<Self> {
        return EnvironmentUpdatingView(content: self, updates: {
            $0.textFieldStyle = style
        })
    }
    
    func buttonStyle<Style: PrimitiveButtonStyle>(_ style: Style) -> EnvironmentUpdatingView<Self> {
        return EnvironmentUpdatingView(content: self, updates: {
            $0.buttonStyle = style
        })
    }
    
    func foregroundColor(_ color: UIColor?) -> EnvironmentUpdatingView<Self> {
        return EnvironmentUpdatingView(content: self, updates: {
            $0.foregroundColor = color
        })
    }
}
