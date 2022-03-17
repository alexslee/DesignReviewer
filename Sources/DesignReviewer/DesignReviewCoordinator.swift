//
//  DesignReviewCoordinator.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import os.log
import UIKit

internal struct DesignReviewColorPickerSessionObserver {
  let initialColor: UIColor
  let changeHandler: ((UIColor) -> Void)?
}

class DesignReviewCoordinator: NSObject, DesignReviewCoordinatorProtocol {
  let coordinatorID = UUID()
  var children = [DesignReviewCoordinatorProtocol]()
  weak var parent: DesignReviewCoordinatorProtocol?

  private let viewModel: DesignReviewViewModel

  private(set) var appWindow: UIWindow?
  static var isPresenting = false
  private var window: UIWindow?

  var userDefinedCustomAttributes = [String: DesignReviewCustomAttributeSet]()
  var onFinish: (() -> Void)?

  private var currentColorPickerObserver: DesignReviewColorPickerSessionObserver?

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
      // wipe indices clean s.t. a subsequent open wouldn't draw rects where the views may no longer exist
      self?.viewModel.selectedReviewableIndices.removeAll()

      self?.userDefinedCustomAttributes.values.forEach({ $0.removeAll() })
      self?.userDefinedCustomAttributes.removeAll()

      self?.onFinish?()

      self?.children.removeAll()
    })
  }

  private func presentReviewHUD() {
    let window: UIWindow

    if #available(iOS 13, *), let scene = appWindow?.windowScene {
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
    guard let rootViewController = window?.rootViewController else { return }

    var customAttributes = userDefinedCustomAttributes[String(describing: reviewable.classForCoder)]

    if let _ = reviewable as? UIView, let viewAttributes = DesignReviewer.customAttributes["UIView"] {
      if customAttributes == nil {
        customAttributes = DesignReviewCustomAttributeSet()
      }
      customAttributes?.merge(with: viewAttributes)
    }

    if let _ = reviewable as? UILabel, let labelAttributes = DesignReviewer.customAttributes["UILabel"] {
      if customAttributes == nil {
        customAttributes = DesignReviewCustomAttributeSet()
      }
      customAttributes?.merge(with: labelAttributes)
    }

    let inspectorViewModel = DesignReviewInspectorViewModel(reviewable: reviewable,
                                                            userDefinedCustomAttributes: customAttributes)

    let newRouter = DesignReviewInspectorRouter(viewController: rootViewController)
    let newCoordinator = DesignReviewInspectorCoordinator(viewModel: inspectorViewModel, router: newRouter)

    newCoordinator.parent = self
    children.append(newCoordinator)

    newCoordinator.start()
  }

  private func refreshSelectionBorders() {
    viewModel.refreshSelectionBorders()
  }

  func toggleHUDVisibility(_ isVisible: Bool) {
    viewModel.toggleHUDVisibility?(isVisible)
  }
}
