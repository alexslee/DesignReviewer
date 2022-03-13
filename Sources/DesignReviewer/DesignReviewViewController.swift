//
//  DesignReviewViewController.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

class DesignReviewViewController: UIViewController {
  private let viewModel: DesignReviewViewModel

  private lazy var designReviewContainerView: DesignReviewContainerView = {
    let view = DesignReviewContainerView(viewModel: viewModel)
    view.delegate = self
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  private lazy var designReviewHUD: DesignReviewHUD = {
    let button = DesignReviewHUD()
    button.tag = 666
    button.addTarget(self, action: #selector(tappedHUD), for: .touchUpInside)
    button.addTarget(self, action: #selector(doubleTappedHUD), for: .editingDidEndOnExit)

    button.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panhandler)))

    return button
  }()

  private var designReviewHUDCenter: CGPoint = .zero

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open var canBecomeFirstResponder: Bool { false }

  init(viewModel: DesignReviewViewModel) {
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)

    setupViewModelBindings()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(designReviewContainerView)

    viewModel.updateReviewables()

    view.addSubview(designReviewHUD)

    NSLayoutConstraint.activate(designReviewContainerView.constraints(toView: view))

    designReviewHUD.frame.size = CGSize(width: 64, height: 64)
    designReviewHUD.center = view.center

    designReviewContainerView.refresh()
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    // naive way to ensure HUD remains on screen is to just re-center on rotation/size change
    designReviewHUD.center = CGPoint(x: size.width / 2, y: size.height / 2)
  }
}

// MARK: - Gesture handlers

extension DesignReviewViewController {
  @objc private func doubleTappedHUD() {
    designReviewContainerView.resetSelectableViews()
    DesignReviewer.finish()
  }

  @objc private func panhandler(_ gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began:
      designReviewHUDCenter = designReviewHUD.center
    case .changed:
      let translation = gestureRecognizer.translation(in: view)
      designReviewHUD.center = CGPoint(x: designReviewHUDCenter.x + translation.x,
                                       y: designReviewHUDCenter.y + translation.y)
    default:
      break
    }
  }

  @objc private func tappedHUD() {
    viewModel.startDesignReview()
  }
}

extension DesignReviewViewController: UIAdaptivePresentationControllerDelegate {
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    designReviewContainerView.refresh(animated: true)
    viewModel.coordinator?.removeAllChildren()
  }
}

extension DesignReviewViewController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController,
                            willShow viewController: UIViewController,
                            animated: Bool) {

    if #available(iOS 14, *), viewController is UIColorPickerViewController {
      return
    } else if viewController is DesignReviewInspectorViewController {
      return
    }

    dismiss(animated: true, completion: {
      self.designReviewContainerView.refresh(animated: true)
      self.viewModel.coordinator?.removeAllChildren()
    })
  }
}

// MARK: - Helpers

extension DesignReviewViewController {
  private func setupViewModelBindings() {
    viewModel.recalculateSelectionBorders = { [weak self] in
      guard let self = self else { return }
      self.designReviewContainerView.refresh(animated: true)
    }

    viewModel.toggleHUDVisibility = { [weak self] (isVisible: Bool) in
      guard let self = self else { return }
      self.toggleHUDVisibility(hidden: !isVisible)
    }
  }

  private func toggleHUDVisibility(hidden: Bool, animated: Bool = false) {
    guard animated else {
      designReviewHUD.isHidden = hidden
      return
    }

    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 1,
      options: .beginFromCurrentState,
      animations: { [weak self] in
        self?.designReviewHUD.isHidden = hidden
    })
  }
}

// MARK: - DesignReviewContainerViewDelegate

extension DesignReviewViewController: DesignReviewContainerViewDelegate {
  func didBegin(in container: DesignReviewContainerView) {
    toggleHUDVisibility(hidden: true, animated: true)
  }

  func didEnd(in container: DesignReviewContainerView) {
    toggleHUDVisibility(hidden: false, animated: true)
  }
}
