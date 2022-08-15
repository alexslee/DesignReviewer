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

  func dismiss() {
    guard let window = viewModel.fakeWindow else { return }

    viewModel.onContainerDisappear = { [weak window, weak viewModel] in
      if (window?.spuddlePresentedViewModel.spuddles ?? []).isEmpty {
        viewModel?.fakeWindow?.removeFromSuperview()
        viewModel?.fakeWindow = nil
        viewModel?.coordinator?.finish()
      }

      SpuddleWindowManager.shared.deleteAsNeeded()
    }

    // TODO: dedicated dismiss animation
    withTransaction(Transaction(animation: viewModel.animation)) { [weak window] in
      window?.spuddlePresentedViewModel.spuddles.removeAll(where: { $0 == self })
    }

    viewModel.onDismiss?()
  }

  func positionDidChange(to newPoint: CGPoint) {
    let bounds = viewModel.fakeWindow?.window?.bounds ?? .zero

    if newPoint.y >= bounds.height - (bounds.height * 0.25) {
      var newFrame = viewModel.staticFrame
      newFrame.origin.y = bounds.height

      viewModel.staticFrame = newFrame
      viewModel.currentFrame = newFrame

      dismiss()
      return
    }

    let sourceFrame = viewModel.sourceFrame().inset(by: viewModel.sourceFrameInset)

    let closestPlacement = SpuddlePlacement.closestPlacement(
      for: newPoint,
      in: sourceFrame,
      spuddleSize: viewModel.currentSize ?? .zero)

    let newFrame = SpuddlePlacement.calculateRelativePosition(
      for: closestPlacement,
      in: sourceFrame,
      with: viewModel.currentSize ?? .zero)

    viewModel.staticFrame = newFrame
    viewModel.currentFrame = newFrame
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
      fakeWindow.movedToWindow = { [weak fakeWindow, weak viewModel, weak window] in
        guard let stillFakeWindow = fakeWindow else { return }
        guard let animation = viewModel?.animation else { return }
        guard let targetWindow = window else { return }
        showSpuddle(in: stillFakeWindow, transaction: Transaction(animation: animation), window: targetWindow)
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
