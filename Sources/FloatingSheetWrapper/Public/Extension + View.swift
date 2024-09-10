//
//  File.swift
//  
//
//  Created by Yuriy on 10.09.2024.
//

import SwiftUI

public extension View {
    func floatingSheet<ScrollContent: View, HeaderContent: View>(
        isShowSheet: Binding<Bool> = .constant(true),
        currentState: Binding<Int> = .constant(0),
        updateContent: Binding<Bool> = .constant(false),
        scrollIsEnambled: Binding<Bool> = .constant(true),
        thresholds: [CGFloat] = [100, 300, 400],
        backgroundColor: Color = .white,
        cornerRadius: CGFloat = 20,
        @ViewBuilder scrollContent: @escaping () -> ScrollContent,
        @ViewBuilder headerContent: @escaping () -> HeaderContent
    ) -> some View {
        self.modifier(
            ScrollViewModifier(
                isShowSheet: isShowSheet,
                currentState: currentState,
                updateContent: updateContent,
                scrollIsEnambled: scrollIsEnambled,
                thresholds: thresholds,
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                scrollContent: scrollContent,
                headerContent: headerContent
            )
        )
    }
}
