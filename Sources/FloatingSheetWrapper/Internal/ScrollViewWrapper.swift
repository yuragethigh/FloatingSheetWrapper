//
//  File.swift
//  
//
//  Created by Yuriy on 10.09.2024.
//

import SwiftUI

internal struct ScrollViewWrapper<Content: View>: UIViewRepresentable {
    
    private let thresholds: [CGFloat]
    @Binding var currentIndex: Int
    @Binding var contentOffset: CGFloat
    @Binding var updateContent: Bool
    @Binding var scrollIsEnambled: Bool
    
    let content: () -> Content
    
    init(
        thresholds: [CGFloat],
        currentIndex: Binding<Int>,
        contentOffset: Binding<CGFloat>,
        updateContent: Binding<Bool>,
        scrollIsEnambled: Binding<Bool>,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.thresholds = thresholds
        self._currentIndex = currentIndex
        self._contentOffset = contentOffset
        self._updateContent = updateContent
        self._scrollIsEnambled = scrollIsEnambled
        self.content = content
    }
    
    func makeUIView(context: UIViewRepresentableContext<ScrollViewWrapper>) -> UIScrollView {
        let sv = UIScrollView()
        sv.backgroundColor = .clear
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = false
        sv.delegate = context.coordinator
        
        layoutContent(sv)
        
        return sv
    }
    
    func updateUIView(_ sv: UIScrollView, context: UIViewRepresentableContext<ScrollViewWrapper>) {
        if updateContent {
            layoutContent(sv)
            updateContent = false
        }
    }
    
    private func layoutContent(_ sv: UIScrollView) {
        let controller = UIHostingController(rootView: content())
        controller.view.backgroundColor = .clear
        sv.isScrollEnabled = scrollIsEnambled
        sv.addSubview(controller.view)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: sv.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: sv.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: sv.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: sv.bottomAnchor),
            controller.view.widthAnchor.constraint(equalTo: sv.widthAnchor)
        ])
        controller.view.layoutIfNeeded()
        controller.view.setNeedsLayout()
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            thresholds: thresholds,
            currentIndex: $currentIndex,
            contentOffset: $contentOffset
        )
    }
    
    internal final class Coordinator: NSObject, UIScrollViewDelegate {
        
        let thresholds: [CGFloat]
        @Binding var currentIndex: Int
        @Binding var contentOffset: CGFloat
        
        init(
            thresholds: [CGFloat],
            currentIndex: Binding<Int>,
            contentOffset: Binding<CGFloat>
        ){
            self.thresholds = thresholds
            self._currentIndex = currentIndex
            self._contentOffset = contentOffset
        }
        
        deinit {
            //            print("deinit")
        }
        
        private enum DragState {
            case drag, scroll, bounce
        }
        
        private var dragState: DragState = .drag
        private var decelerate: Bool = true
        
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let yOffset = scrollView.contentOffset.y
            
            guard
                let viewHeight = thresholds.last,
                let minHeight = thresholds.first
            else {
                return
            }
            
            let getSizeY = thresholds[currentIndex] + contentOffset
            
            switch dragState {
            case .drag:
                
                if getSizeY >= viewHeight {
                    currentIndex = thresholds.count - 1
                    contentOffset = 0
                    dragState = .scroll
                    scrollView.setContentOffset(CGPoint.zero, animated: false)
                    
                } else {
                    scrollView.contentOffset.y = 0
                    guard getSizeY >= minHeight else {
                        return
                    }
                    contentOffset += yOffset
                    
                }
                
            case .scroll:
                
                if yOffset < 0 {
                    scrollView.contentOffset.y = 0
                    contentOffset += yOffset
                    dragState = .drag
                    
                } else if decelerate {
                    
                    dragState = .bounce
                }
                
            case .bounce:
                
                decelerate = false
                if yOffset == 0 {
                    
                    self.dragState = .scroll
                }
            }
            
        }
        
        private func switchSize(_ scrollView: UIScrollView) {
            let currentY = thresholds[currentIndex] + contentOffset
            
            let nearestIndex = thresholds.enumerated().min(by: { abs($0.element - currentY) < abs($1.element - currentY) })?.offset ?? currentIndex
            
            currentIndex = nearestIndex
            contentOffset = 0
            
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            switchSize(scrollView)
            
            if dragState != .bounce {
                self.decelerate = decelerate
            }
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            
            let thresholdVelocity = 1.5
            
            guard dragState == .drag else {
                return
            }
            targetContentOffset.pointee.y = 0
            
            if velocity.y > thresholdVelocity {
                currentIndex = min(currentIndex + 1, thresholds.count - 1)
                contentOffset = 0
                
            } else if velocity.y < -thresholdVelocity {
                currentIndex = max(currentIndex - 1, 0)
                contentOffset = 0
                
            }
        }
    }
}
