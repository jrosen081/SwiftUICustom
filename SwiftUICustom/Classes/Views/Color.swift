//
//  Color.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/6/21.
//

import Foundation

public struct Color: View {
    let uiColor: UIColor
    
    init(uiColor: UIColor) {
        self.uiColor = uiColor
    }
    
    public var body: BackgroundColorView<Spacer> {
        Spacer().background(self)
    }
    
    public func opacity(_ val: CGFloat) -> Color {
        .init(uiColor: self.uiColor.withAlphaComponent(val))
    }
    
    public static var red: Color {
        .init(uiColor: .systemRed)
    }
    
    public static var green: Color {
        .init(uiColor: .systemGreen)
    }
    
    public static var yellow: Color {
        .init(uiColor: .systemYellow)
    }
    
    public static var purple: Color {
        .init(uiColor: .systemPurple)
    }
    
    public static var orange: Color {
        .init(uiColor: .systemOrange)
    }
    
    public static var pink: Color {
        .init(uiColor: .systemPink)
    }
    
    public static let clear: Color = .init(uiColor: .clear)
    
    public static let black: Color = .init(uiColor: .black)
    
    public static let white: Color = .init(uiColor: .white)
    
    public static let gray: Color = .init(uiColor: .systemGray)
}
