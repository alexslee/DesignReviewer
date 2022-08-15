//
//  SpuddleFakeWindowView.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import SwiftUI
import UIKit

// trying out a UIView to manage hittesting of the contained SwiftUI view, versus a UIWindow which was wonky in the past
class SpuddleFakeWindowView: UIView {
  var movedToWindow: (() -> Void)?

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    guard let window = window else { return }
    let container = SpuddleContainerView(viewModel: spuddlePresentedViewModel)
      .environment(\.window, window)

    let hostingController = UIHostingController(rootView: container)
    hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostingController.view.backgroundColor = .clear
    hostingController.view.frame = bounds

    addSubview(hostingController.view)

    setNeedsLayout()
    layoutIfNeeded()

    movedToWindow?()
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard event.map({ $0.type == .touches }) ?? true else { return nil }

    for spuddle in spuddlePresentedViewModel.spuddles.reversed() {
      if spuddle.viewModel.currentFrame.contains(point) {
        spuddlePresentedViewModel.spuddles.forEach { dismissIfNeeded($0) }
        return super.hitTest(point, with: event) // don't let the touch keep propagating
      }

      if spuddle.viewModel.shouldBlockOutsideTouches {
        return super.hitTest(point, with: event)
      }
    }

    return nil
  }

  // MARK: - Helpers

  private func dismissIfNeeded(_ spuddle: Spuddle) {
    // TODO: dismiss functionality
  }
}
