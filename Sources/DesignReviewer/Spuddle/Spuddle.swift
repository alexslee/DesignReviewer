//
//  Spuddle.swift
//  
//
//  Created by Alexander Lee on 2022-08-14.
//

import Foundation
import SwiftUI
import UIKit

/**
 ‘Spuddle’ (17th-century): to work ineffectively; to be extremely busy whilst achieving absolutely nothing.
 */
struct Spuddle: Identifiable, Equatable {
  var id: UUID { viewModel.id }

  static func == (lhs: Spuddle, rhs: Spuddle) -> Bool {
    lhs.id == rhs.id
  }

  let viewModel: SpuddleViewModel
  let view: AnyView
  let backgroundView: AnyView

  init<MainContent: View, BackgroundContent: View>(
    viewModel: SpuddleViewModel,
    @ViewBuilder view: @escaping () -> MainContent,
    @ViewBuilder backgroundView: @escaping () -> BackgroundContent = { Color.clear }) {
      self.viewModel = viewModel
      self.view = AnyView(view().environmentObject(viewModel))
      self.backgroundView = AnyView(backgroundView().environmentObject(viewModel))
    }

  func present(in window: UIWindow) {
    let transaction = Transaction(animation: viewModel.animation)

    viewModel.currentTransaction = transaction

    let fakeWindow: SpuddleFakeWindowView
    if let currentFakeWindow = window.fakeWindowView {
      fakeWindow = currentFakeWindow
      showSpuddle(in: currentFakeWindow, transaction: transaction, window: window)
    } else {
      fakeWindow = SpuddleFakeWindowView(frame: window.bounds)
      fakeWindow.movedToWindow = { [weak fakeWindow] in
        if let stillFakeWindow = fakeWindow { showSpuddle(in: stillFakeWindow, transaction: transaction, window: window) }
      }

      window.addSubview(fakeWindow)
    }

    viewModel.fakeWindow = fakeWindow
  }

  func respondToSizeChange(_ newSize: CGSize?) {
    let newFrame = SpuddlePlacement.calculateRelativePosition(
      for: viewModel.placement,
      in: viewModel.sourceFrame().inset(by: viewModel.sourceFrameInset),
      with: newSize ?? .zero)

    viewModel.currentFrame = newFrame
    viewModel.currentSize = newSize
    viewModel.staticFrame = newFrame
  }

  // MARK: - Helpers

  private func showSpuddle(in fakeWindow: SpuddleFakeWindowView, transaction: Transaction, window: UIWindow) {
    withTransaction(transaction) {
      window.spuddlePresentedViewModel.spuddles.append(self)
    }
  }
}
