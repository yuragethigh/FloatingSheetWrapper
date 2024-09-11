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
                        
                        VStack(spacing: 0) {
                            
                            headerContent
                                .gesture(gesture)
                            
                            ScrollViewWrapper(
                                thresholds: thresholds,
                                currentIndex: $currentState,
                                contentOffset: $contentOffset,
                                updateContent: $updateContent,
                                scrollIsEnambled: $scrollIsEnambled
                            ) {
                                scrollContent
                            }
                            
                        } // : VStack
                        
                        .background(
                            backgroundColor
                        )
                        .cornerRadius(
                            cornerRadius,
                            corners: [.topLeft, .topRight]
                        )
                        .animation(
                            .spring(duration: 0.25),
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
                height: calculateHeight()
            )
            .animation(
                .spring(duration: 0.2),
                value: isShowSheet
            )
            
        }  // : ZStack
    }
    
    private func calculateHeight() -> CGFloat {
        return max(thresholds[currentState] + contentOffset, thresholds.first ?? 0)
    }

    
    private var gesture: some Gesture {
        DragGesture()
            .onChanged({ value in
                let translation = -value.translation.height
                
                contentOffset = translation
            })
            .onEnded { value in
                let velocity = -value.velocity.height
                let thresholdVelocity = 100.0
                let currentY = thresholds[currentState] + contentOffset

                if velocity > thresholdVelocity {
                    currentState = min(currentState + 1, thresholds.count - 1)
                    contentOffset = 0

                } else if velocity < -thresholdVelocity {
                    currentState = max(currentState - 1, 0)
                    contentOffset = 0

                } else {
                    let nearestIndex = thresholds
                        .enumerated()
                        .min(by: { abs($0.element - currentY) < abs($1.element - currentY) })?.offset ?? currentState

                    currentState = nearestIndex
                    contentOffset = 0
                }
            }
    }

}

