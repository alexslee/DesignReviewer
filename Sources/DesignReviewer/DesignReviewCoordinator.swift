//
//  DesignReviewCoordinator.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import os.log
import UIKit

class DesignReviewCoordinator: NSObject {
  private let viewModel: DesignReviewViewModel

  private(set) var appWindow: UIWindow?
  static var isPresenting = false
  private var window: UIWindow?

  init(viewModel: DesignReviewViewModel, appWindow: UIWindow?) {
    self.viewModel = viewModel
    self.appWindow = appWindow
    super.init()
  }

  func start() {
    guard !Self.isPresenting else { return }

    DispatchQueue.main.async {
      self.presentReviewHUD()
    }
  }

  func finish() {
    guard Self.isPresenting else { return }

    DispatchQueue.main.async {
      self.dismissReviewHUD()
    }
  }

  func dismissReviewHUD() {
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.window?.alpha = 0
    }, completion: { [weak self] _ in

      self?.appWindow?.makeKeyAndVisible()

      self?.window?.rootViewController = nil
      self?.window = nil

      Self.isPresenting = false
    })
  }

  private func presentReviewHUD() {
    let window: UIWindow

    if let scene = appWindow?.windowScene {
      window = UIWindow(windowScene: scene)
    } else {
      window = UIWindow(frame: UIScreen.main.bounds)
    }

    window.backgroundColor = .clear

    window.alpha = 0
    window.frame = appWindow?.bounds ?? .zero
    window.windowLevel = .normal
    window.rootViewController = DesignReviewViewController(viewModel: viewModel)

    viewModel.coordinator = self

    window.makeKeyAndVisible()

    UIView.animate(withDuration: 0.3) {
      window.alpha = 1
    }

    self.window = window
    Self.isPresenting = true
  }

  func presentDesignReview(for reviewable: DesignReviewable) {
    if reviewable as? UIView != nil {
      let inspectorViewModel = DesignReviewInspectorViewModel(reviewable: reviewable)
      let viewController = DesignReviewInspectorViewController(viewModel: inspectorViewModel)

      inspectorViewModel.coordinator = self

      if let navigationController = window?.rootViewController?.presentedViewController as? UINavigationController {
        navigationController.pushViewController(viewController, animated: true)
        return
      }

      window?.rootViewController?.definesPresentationContext = true

      let newNavController = UINavigationController(rootViewController: viewController)
      window?.rootViewController?.present(newNavController, animated: true)
      newNavController.presentationController?.delegate = self
    }
  }

  func presentExplodedHierarchy(reviewable: DesignReviewable) {
    guard let appWindow = appWindow else { return }

    let explodedViewModel = DesignReviewExplodedHierarchyViewModel(coordinator: self, rootReviewable: reviewable)
    let viewController = DesignReviewExplodedHierarchyViewController(root: appWindow, viewModel: explodedViewModel)

    if let navController = window?.rootViewController?.presentedViewController as? UINavigationController {
      CATransaction.begin()
      CATransaction.setCompletionBlock({ viewController.jumpStart() })
      navController.pushViewController(viewController, animated: true)
      CATransaction.commit()
    }
  }

  private func refreshHighlights() {
    viewModel.refreshHighlights()
  }

  func toggleHUDVisibility(_ isVisible: Bool) {
    viewModel.toggleHUDVisibility?(isVisible)
  }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension DesignReviewCoordinator: UIAdaptivePresentationControllerDelegate {
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    refreshHighlights()
  }
}
