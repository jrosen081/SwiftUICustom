//
//  ViewBuilder.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

@resultBuilder
public struct ViewBuilder {
	
	public static func buildBlock() -> EmptyView {
		return EmptyView()
	}
	
	public static func buildBlock<Content: View>(_ content: Content) -> Content {
		return content
	}
	
	public static func buildBlock<C1: View, C2: View>(_ c1: C1, _ c2: C2) -> TupleView<(C1, C2)> {
		return TupleView(value: (c1, c2))
	}
	
	public static func buildBlock<C1: View, C2: View, C3: View>(_ c1: C1, _ c2: C2, _ c3: C3) -> TupleView<(C1, C2, C3)> {
		return TupleView(value: (c1, c2, c3))
	}
	
	public static func buildBlock<C1: View, C2: View, C3: View, C4: View>(_ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleView<(C1, C2, C3, C4)> {
		return TupleView(value: (c1, c2, c3, c4))
	}
	
	public static func buildBlock<C1: View, C2: View, C3: View, C4: View, C5: View>(_ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleView<(C1, C2, C3, C4, C5)> {
		return TupleView(value: (c1, c2, c3, c4, c5))
	}
	
	public static func buildBlock<C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>(_ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleView<(C1, C2, C3, C4, C5, C6)> {
		return TupleView(value: (c1, c2, c3, c4, c5, c6))
	}
	
	public static func buildBlock<C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>(_ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleView<(C1, C2, C3, C4, C5, C6, C7)> {
		return TupleView(value: (c1, c2, c3, c4, c5, c6, c7))
	}
	
	public static func buildBlock<C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>(_ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleView<(C1, C2, C3, C4, C5, C6, C7, C8)> {
		return TupleView(value: (c1, c2, c3, c4, c5, c6, c7, c8))
	}
	
	public static func buildBlock<C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>(_ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleView<(C1, C2, C3, C4, C5, C6, C7, C8, C9)> {
		return TupleView(value: (c1, c2, c3, c4, c5, c6, c7, c8, c9))
	}

	public static func buildBlock<C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View>(_ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10) -> TupleView<(C1, C2, C3, C4, C5, C6, C7, C8, C9, C10)> {
		return TupleView(value: (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10))
	}
	
	public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> ConditionalContent<TrueContent, FalseContent> {
		return ConditionalContent(actualContent: .first(first))
	}
	
	public static func buildEither<TrueContent, FalseContent>(second: FalseContent) -> ConditionalContent<TrueContent, FalseContent> {
		return ConditionalContent(actualContent: .second(second))
	}
	
	public static func buildIf<Content: View>(_ view: Content?) -> ConditionalContent<Content, EmptyView> {
		if let view = view {
			return ConditionalContent(actualContent: .first(view))
		} else {
			return ConditionalContent(actualContent: .second(EmptyView()))
		}
	}
    
    public static func buildLimitedAvailability<Content: View>(_ component: Content) -> AnyView {
        AnyView(component)
    }
    
    static func buildBlock(_ views: [_BuildingBlock]) -> TupleView<[_BuildingBlock]> {
        return TupleView(value: views)
    }
}
