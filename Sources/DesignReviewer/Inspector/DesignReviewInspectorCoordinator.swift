//
//  DesignReviewInspectorCoordinator.swift
//  
//
//  Created by Alex Lee on 3/11/22.
//

import Foundation
import UIKit

class DesignReviewInspectorRouter {
  private(set) weak var viewController: UIViewController?

  init(viewController: UIViewController) {
    self.viewController = viewController
  }

  func beginInspection(_ viewController: UIViewController) {
    if let navController = self.viewController?.presentedViewController as? UINavigationController {
      navController.pushViewController(viewController, animated: true)
    } else {
      let newNavController = UINavigationController(rootViewController: viewController)
      self.viewController?.present(newNavController, animated: true)
    }
  }

  func pushIfPossible(_ viewController: UIViewController) {
    (viewController as? UINavigationController)?.pushViewController(viewController, animated: true)
  }
}

class DesignReviewInspectorCoordinator: NSObject, DesignReviewCoordinatorProtocol {
  var children = [DesignReviewCoordinatorProtocol]()
  let coordinatorID = UUID()
  weak var parent: DesignReviewCoordinatorProtocol?

  private let router: DesignReviewInspectorRouter
  private let viewModel: DesignReviewInspectorViewModel

  private var currentColorPickerObserver: DesignReviewColorPickerSessionObserver?

  init(viewModel: DesignReviewInspectorViewModel, router: DesignReviewInspectorRouter) {
    self.router = router
    self.viewModel = viewModel
  }

  func start() {
    let viewController = DesignReviewInspectorViewController(viewModel: viewModel)

    viewModel.coordinator = self

    router.beginInspection(viewController)
  }

  func finish() {
    guard children.isEmpty else { return }

    parent?.removeAllChildren()
  }

  func showAlert(viewModel: DesignReviewSuboptimalAlertViewModelProtocol,
                 in viewController: UIViewController) {
    let router = DesignReviewSuboptimalAlertRouter(viewController: viewController)
    let coordinator = DesignReviewSuboptimalAlertCoordinator(viewModel: viewModel,
                                                             router: router)

    children.append(coordinator)
    coordinator.start()
  }

  func presentDesignReview(for reviewable: DesignReviewable) {
    guard let currentContext = router.viewController else { return }
    let customAttributes = DesignReviewer.customAttributes[String(describing: reviewable.classForCoder)]

    let newViewModel = DesignReviewInspectorViewModel(
      reviewable: reviewable,
      userDefinedCustomAttributes: customAttributes)

    let newRouter = DesignReviewInspectorRouter(viewController: currentContext)
    let newCoordinator = DesignReviewInspectorCoordinator(viewModel: newViewModel, router: newRouter)
    newViewModel.coordinator = newCoordinator

    newCoordinator.parent = self
    children.append(newCoordinator)
    newCoordinator.start()
  }

  func showColorPicker(initialColor: UIColor, changeHandler: ((UIColor) -> Void)?) {
    guard #available(iOS 14, *) else { return }
    let pickerViewController = UIColorPickerViewController()
    pickerViewController.view.backgroundColor = .background
    pickerViewController.selectedColor = initialColor

    pickerViewController.delegate = self

    currentColorPickerObserver = DesignReviewColorPickerSessionObserver(initialColor: initialColor,
                                                                        changeHandler: changeHandler)

    router.pushIfPossible(pickerViewController)
  }
}

// MARK: - UIColorPickerViewControllerDelegate

@available(iOS 14, *)
extension DesignReviewInspectorCoordinator: UIColorPickerViewControllerDelegate {
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
