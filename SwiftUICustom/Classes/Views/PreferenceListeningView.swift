//
//  PreferenceListeningView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/28/21.
//

import Foundation

public struct PreferenceListeningView<Content: View, K: PreferenceKey>: View {
    public struct ListeningView: View {
        let content: Content
        @EnvironmentObject var listener: PreferenceKeyValue<K>
        let action: (K.Value) -> Void
        
        public var body: OnChangeView<Int, Content> {
            return self.content.onChange(of: listener.changeCount) { _ in
                action(listener.value)
            }
        }
    }
    
    @Environment(\.[ObjectIdentifier(EnvironmentPreferenceKey<K>.self), PreferenceKeyValue(value: K.defaultValue)]) var preference: PreferenceKeyValue<K>
    let content: Content
    let action: (K.Value) -> Void
    
    public var body: EnvironmentUpdatingView<ListeningView> {
        ListeningView(content: self.content, action: self.action)
            .environmentObject(preference)
    }
}

public extension View {
    func onPreferenceChange<K: PreferenceKey>(key: K.Type = K.self, perform: @escaping (K.Value) -> Void) -> PreferenceListeningView<Self, K> {
        return PreferenceListeningView(content: self, action: perform)
    }
}
