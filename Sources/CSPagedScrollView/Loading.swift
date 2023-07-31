//
//  Loading.swift
//  chatgirl
//
//  Created by kourou on 2023/6/15.
//

import SwiftUI

public struct LoadingViewModifier: ViewModifier {
    /// 空状态的条件
    public var isLoading: Bool

    public func body(content: Content) -> some View {
        if isLoading {
            ProgressView()
                .frame(maxHeight: .infinity)
        } else {
            content
        }
    }
}

extension View {
    public func loading(control: Bool) -> some View {
        modifier(LoadingViewModifier(isLoading: control))
    }
}
