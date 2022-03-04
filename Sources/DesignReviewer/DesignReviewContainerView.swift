//
//  DesignReviewContainerView.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

protocol DesignReviewContainerViewDelegate: AnyObject {
  func didBegin(in container: DesignReviewContainerView)
  func didEnd(in container: DesignReviewContainerView)
}

class DesignReviewContainerView: UIView {
  weak var delegate: DesignReviewContainerViewDelegate?

  // MARK: - Subviews

  /// 'layout' here just refers to the container of the labels displaying spacing between primary + secondary
  private lazy var designReviewSpecContainerView: DesignReviewSpecContainerView = {
    let view = DesignReviewSpecContainerView(
      containerView: self,
      borderColor: .monochrome0,
      borderWidth: 1,
      selectableStyle: .dashed)
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  /// 'primary' here just refers to MRU, if multiple views are highlighted
  private var primaryView: DesignReviewSelectableView?

  /// 'secondary' here just refers to LRU, if multiple views are highlighted
  private var secondaryView: DesignReviewSelectableView?

  // MARK: - Internal properties
  private lazy var feedbackGenerator = UIImpactFeedbackGenerator()

  private var isPanning = false

  private var primaryRect: CGRect {
    guard let primaryIndex = viewModel.selectedReviewableIndices.last else { return .zero }
    return viewModel.reviewables[primaryIndex].convertBounds(to: self)
  }

  private var secondaryRect: CGRect {
    guard let secondaryIndex = viewModel.selectedReviewableIndices.first else { return .zero }
    return viewModel.reviewables[secondaryIndex].convertBounds(to: self)
  }

  private let viewModel: DesignReviewViewModel

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(viewModel: DesignReviewViewModel) {
    self.viewModel = viewModel

    super.init(frame: .zero)

    let singleTapper = UITapGestureRecognizer(target: self, action: #selector(tapped))
    addGestureRecognizer(singleTapper)

    let doubleTapper = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    doubleTapper.numberOfTapsRequired = 2
    addGestureRecognizer(doubleTapper)

    singleTapper.require(toFail: doubleTapper)

    addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panhandler)))

    resetSelectableViews()
  }

  func refresh(animated: Bool = false) {
    updateHighlights(animated: animated)

    primaryView?.setNeedsDisplay()
    secondaryView?.setNeedsDisplay()
    designReviewSpecContainerView.setNeedsDisplay()
  }

  // MARK: - Gesture recognizer handlers

  @objc private func tapped(_ gestureRecognizer: UITapGestureRecognizer) {
    showUsOnTheDoll(gestureRecognizer.location(in: self))
    if gestureRecognizer.state == .ended {
      delegate?.didEnd(in: self)
    }
  }

  @objc private func doubleTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    showUsOnTheDoll(gestureRecognizer.location(in: self))
  }

  @objc private func panhandler(_ gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began:
      isPanning = true
      delegate?.didBegin(in: self)
    case .changed:
      showUsOnTheDoll(gestureRecognizer.location(in: self))
    default:
      isPanning = false
      delegate?.didEnd(in: self)
    }
  }

  // MARK: - Helpers

  func resetSelectableViews() {
    primaryView?.removeFromSuperview()
    secondaryView?.removeFromSuperview()

    let newPrimary = DesignReviewSelectableView(borderColor: .success3, borderWidth: 2, selectableStyle: .solid)
    addSubview(newPrimary)
    primaryView = newPrimary

    let newSecondary = DesignReviewSelectableView(borderColor: .monochrome5, borderWidth: 2, selectableStyle: .solid)
    addSubview(newSecondary)
    secondaryView = newSecondary
  }

  private func showUsOnTheDoll(_ point: CGPoint) {
    let zipped = zip(viewModel.reviewables.indices, viewModel.reviewables)

    guard let (index, _) = zipped.first(where: { $0.1.convertBounds(to: self).contains(point) }) else {
      return
    }

    guard viewModel.selectedReviewableIndices.contains(index) else {
      selectReviewable(at: index, animated: true)
      return
    }

    if !isPanning {
      viewModel.selectedReviewableIndices.reverse()
      updateHighlights(animated: true)
    }
  }

  private func selectReviewable(at index: Int, animated: Bool = false) {
    viewModel.updateSelectedIndices(index: index, isPanning: isPanning)
    updateHighlights(animated: animated)
    feedbackGenerator.prepare()
    feedbackGenerator.impactOccurred()
  }

  /// Updates the border highlights around the currently selected view(s), and re-calculates specs if needed.
  func updateHighlights(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.3) { [weak self] in
        guard let self = self else { return }

        self.primaryView?.frame = self.primaryRect
        self.secondaryView?.frame = self.secondaryRect
      }
    } else {
      primaryView?.frame = primaryRect
      secondaryView?.frame = secondaryRect
    }

    var primary: UIView?
    if let first = viewModel.selectedReviewableIndices.last {
      primary = viewModel.reviewables[first] as? UIView
    }

    var secondary: UIView?
    if let second = viewModel.selectedReviewableIndices.first {
      secondary = viewModel.reviewables[second] as? UIView
    }

    designReviewSpecContainerView.frame = primaryRect.union(secondaryRect)

    designReviewSpecContainerView.primaryView = primary
    designReviewSpecContainerView.secondaryView = secondary
    designReviewSpecContainerView.primarySelectionView = primaryView
    designReviewSpecContainerView.secondarySelectionView = secondaryView

    if animated {
      UIView.animate(
        withDuration: 0.2,
        delay: 0,
        usingSpringWithDamping: 0.9,
        initialSpringVelocity: 1.1,
        options: .beginFromCurrentState,
        animations: { [weak self] in
          self?.designReviewSpecContainerView.refreshLayoutContents()
        }, completion: nil)
    } else {
      designReviewSpecContainerView.refreshLayoutContents()
    }
  }
}
