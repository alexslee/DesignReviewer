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

  var currentTransaction: Transaction?
  @Published var currentFrame: CGRect = .zero
  @Published var currentSize: CGSize? = nil

  let id = UUID()

  weak var fakeWindow: SpuddleFakeWindowView? = nil
  weak var coordinator: DesignReviewCoordinatorProtocol?

  var onContainerDisappear: (() -> Void)?

  /**
   The frame that the popover attaches to or is placed within (configure in `position`). This must be in global window coordinates.

   If you're using SwiftUI, this is automatically provided.
   If you're using UIKit, you must provide this. Use `.windowFrame()` to convert to window coordinates.

       attributes.sourceFrame = { [weak button] in /// `weak` to prevent a retain cycle
           button.windowFrame()
       }
   */
  var sourceFrame: (() -> CGRect)
  var sourceFrameInset: UIEdgeInsets
  /// The frame of the popover, without drag gesture offset applied.
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
