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

  var userDefinedCustomAttributes = [String: Set<DesignReviewCustomAttribute>]()

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
    let customAttributes = userDefinedCustomAttributes[String(describing: reviewable.classForCoder)]

    let inspectorViewModel = DesignReviewInspectorViewModel(reviewable: reviewable,
                                                            userDefinedCustomAttributes: customAttributes)
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

  func showColorPicker(initialColor: UIColor, changeHandler: ((UIColor) -> Void)?) {
    guard #available(iOS 14, *) else { return }
    let pickerViewController = UIColorPickerViewController()
    pickerViewController.view.backgroundColor = .background
    pickerViewController.selectedColor = initialColor

    pickerViewController.delegate = self

    currentColorPickerObserver = DesignReviewColorPickerSessionObserver(initialColor: initialColor,
                                                                        changeHandler: changeHandler)

    if let navigationController = window?.rootViewController?.presentedViewController as? UINavigationController {
      navigationController.pushViewController(pickerViewController, animated: true)
      return
    }
  }

  private func refreshHighlights() {
    viewModel.refreshHighlights()
  }

  func toggleHUDVisibility(_ isVisible: Bool) {
    viewModel.toggleHUDVisibility?(isVisible)
  }

  struct DesignReviewColorPickerSessionObserver {
    let initialColor: UIColor
    let changeHandler: ((UIColor) -> Void)?
  }

  private var currentColorPickerObserver: DesignReviewColorPickerSessionObserver?
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension DesignReviewCoordinator: UIAdaptivePresentationControllerDelegate {
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    refreshHighlights()
  }
}

@available(iOS 14, *)
extension DesignReviewCoordinator: UIColorPickerViewControllerDelegate {
  func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
    currentColorPickerObserver = nil
  }

  func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
    if viewController.selectedColor != currentColorPickerObserver?.initialColor {
      currentColorPickerObserver?.changeHandler?(viewController.selectedColor)
    }
  }

  func colorPickerViewController(_ viewController: UIColorPickerViewController,
                                 didSelect color: UIColor,
                                 continuously: Bool) {
      if color != currentColorPickerObserver?.initialColor {
        currentColorPickerObserver?.changeHandler?(color)
      }
    }
}
