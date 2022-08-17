//
//  SpuddleViewModel.swift
//  
//
//  Created by Alexander Lee on 2022-08-14.
//

import Foundation
import SwiftUI

class SpuddleViewModel: ObservableObject {
  let animation: Animation
  let placement: SpuddlePlacement
  let transition: AnyTransition
  let dismissTransition: AnyTransition
  let shouldBlockOutsideTouches: Bool
  var onDismiss: (() -> Void)?

  @Published var currentFrame: CGRect = .zero
  @Published var currentSize: CGSize? = nil
  var currentTransaction: Transaction?

  let id = UUID()

  weak var fakeWindow: SpuddleFakeWindowView? = nil
  weak var coordinator: DesignReviewCoordinatorProtocol?

  var onContainerDisappear: (() -> Void)?

  // Warning: make sure this is in global window coordinates.
  var sourceFrame: (() -> CGRect)

  var sourceFrameInset: UIEdgeInsets

  // The frame of the spuddle without any drag gesture offset.
  @Published var staticFrame = CGRect.zero

  init(animation: Animation = .spuddleSpringyDefault,
       placement: SpuddlePlacement,
       transition: AnyTransition = .opacity,
       dismissTransition: AnyTransition = .opacity,
       shouldBlockOutsideTouches: Bool = true,
       sourceFrame: @escaping (() -> CGRect) = { .zero },
       sourceFrameInset: UIEdgeInsets = .zero,
       onDismiss: (() -> Void)?) {
    self.animation = animation
    self.placement = placement
    self.onDismiss = onDismiss
    self.transition = transition
    self.dismissTransition = transition
    self.shouldBlockOutsideTouches = shouldBlockOutsideTouches
    self.sourceFrame = sourceFrame
    self.sourceFrameInset = sourceFrameInset
  }
}
