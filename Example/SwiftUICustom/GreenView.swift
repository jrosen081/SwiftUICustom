//
//  GreenView.swift
//  SwiftUICustom_Example
//
//  Created by Jack Rosen on 9/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUICustom

struct GreenView: ViewModifier {
	func body(content: Content) -> ColorView<Content>{
		content.foregroundColor(.systemGreen)
	}
}
