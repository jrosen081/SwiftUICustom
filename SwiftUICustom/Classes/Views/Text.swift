//
//  Text.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

public struct Text: View {
    public enum Case {
        case lowercase
        case uppercase
        
        func updateText(_ str: String) -> String {
            switch self {
            case .lowercase: return str.lowercased()
            case .uppercase: return str.uppercased()
            }
        }
    }
	let text: String
	
	public init(_ text: String) {
		self.text = text
	}
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let label = UILabel(frame: .zero)
		setupData(label: label, environment: environment)
		return SwiftUILabel(label: label)
	}
	
	func setupData(label: UILabel, environment: EnvironmentValues) {
		label.translatesAutoresizingMaskIntoConstraints = false
        label.text = environment.textCase?.updateText(text) ?? text
		label.textAlignment = environment.multilineTextAlignment
		label.textColor = environment.foregroundColor ?? environment.defaultForegroundColor
        label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = environment.minimumScaleFactor
		label.font = environment.font
		label.allowsDefaultTighteningForTruncation = environment.allowsTightening
        label.numberOfLines = environment.lineLimit ?? 0
        label.lineBreakMode = environment.truncationType
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let swiftUILabel = view as? SwiftUILabel else { return }
		setupData(label: swiftUILabel.label, environment: environment)
	}
	
}

internal class SwiftUILabel: SwiftUIView {
	let label: UILabel
    	
	init(label view: UILabel) {
		self.label = view
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.isUserInteractionEnabled = false
		self.addSubview(view)
        view.setContentCompressionResistancePriority(.init(240), for: .horizontal)
        setContentCompressionResistancePriority(.init(240), for: .horizontal)
        self.setupFullConstraints(view, self)
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
