//
//  File.swift
//  
//
//  Created by Yuriy on 10.09.2024.
//

import SwiftUI

internal struct ScrollViewModifier<ScrollContent: View, HeaderContent: View>: ViewModifier {
    
    @State private var contentOffset: CGFloat = .zero
    @Binding private var isShowSheet: Bool
    @Binding private var currentState: Int
    @Binding private var updateContent: Bool
    @Binding private var scrollIsEnambled: Bool
    private let thresholds: [CGFloat]
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let scrollContent: ScrollContent
    private let headerContent: HeaderContent
    
    init(
        isShowSheet: Binding<Bool>,
        currentState: Binding<Int>,
        updateContent: Binding<Bool>,
        scrollIsEnambled: Binding<Bool>,
        thresholds: [CGFloat],
        backgroundColor: Color,
        cornerRadius: CGFloat,
        @ViewBuilder scrollContent: () -> ScrollContent,
        @ViewBuilder headerContent: () -> HeaderContent
    ) {
        self._isShowSheet = isShowSheet
        self._currentState = currentState
        self._updateContent = updateContent
        self._scrollIsEnambled = scrollIsEnambled
        self.thresholds = thresholds
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.scrollContent = scrollContent()
        self.headerContent = headerContent()
    }
    
    func body(content: Content) -> some View {
        
        ZStack(alignment: .bottom) {
            
            content
            
            ZStack(alignment: .bottom) {
                
                if isShowSheet {
                    
                    GeometryReader { proxy in
                        
                        ScrollViewWrapper(
                            thresholds: thresholds,
                            currentIndex: $currentState,
                            contentOffset: $contentOffset,
                            updateContent: $updateContent,
                            scrollIsEnambled: $scrollIsEnambled
                        ) {
                            scrollContent
                        }
                        .background(
                            backgroundColor
                        )
                        .overlay(
                            headerContent
                                .allowsHitTesting(false)
                            ,alignment: .top
                        )
                        .cornerRadius(
                            cornerRadius,
                            corners: [.topLeft, .topRight]
                        )
                        .animation(
                            .spring(duration: 0.25, bounce: 0.25),
                            value: contentOffset
                        )
                        .animation(
                            .spring(duration: 0.25),
                            value: currentState
                        )
                        
                    } // : GeometryReader
                    .transition(.move(edge: .bottom))
                }
                
            } // : ZStack
            .frame(
                height: thresholds[currentState] + contentOffset
            )
            .animation(
                .spring(duration: 0.2),
                value: isShowSheet
            )
            
        }  // : ZStack
    }
}

