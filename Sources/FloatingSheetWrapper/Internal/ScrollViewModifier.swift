//
//  File.swift
//  
//
//  Created by Yuriy on 10.09.2024.
//

import SwiftUI

internal struct ScrollViewModifier<ScrollContent: View, HeaderContent: View, ButtonClosed: View>: ViewModifier {

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
    private let buttonClosed: ButtonClosed

    init(
        isShowSheet: Binding<Bool>,
        currentState: Binding<Int>,
        updateContent: Binding<Bool>,
        scrollIsEnambled: Binding<Bool>,
        thresholds: [CGFloat],
        backgroundColor: Color,
        cornerRadius: CGFloat,
        @ViewBuilder scrollContent: () -> ScrollContent,
        @ViewBuilder headerContent: () -> HeaderContent,
        @ViewBuilder buttonClosed: () -> ButtonClosed
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
        self.buttonClosed = buttonClosed()
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
                        .overlay(
                            buttonClosed, alignment: .topTrailing
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
                        .onChange(of: currentState) { newValue in
                            guard newValue == 0 else  {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isShowSheet = false
                            }
                        }
                        .onDisappear{
                            print("onDisappear")
                        }

                    } // : GeometryReader
                    .transition(.move(edge: .bottom))
                }

            } // : ZStack
            .frame(
                height: calculateHeight
            )
            .animation(
                .spring(duration: 0.2),
                value: isShowSheet
            )

        }  // : ZStack
    }
    private var calculateHeight: CGFloat {
        return thresholds[currentState] + contentOffset
    }
}
