//
//  Color.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/6/21.
//

import Foundation

public typealias Color = UIColor

extension Color: View {
    public var body: BackgroundColorView<Spacer> {
        Spacer().background(self)
    }
}
