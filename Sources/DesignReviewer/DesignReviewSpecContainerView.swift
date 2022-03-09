//
//  DesignReviewSpecContainerView.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

class DesignReviewSpecContainerView: DesignReviewSelectableView {
  // MARK: - Reference views

  weak var containerView: DesignReviewContainerView?
  weak var primaryView: UIView?
  weak var secondaryView: UIView?

  weak var primarySelectionView: DesignReviewSelectableView?
  weak var secondarySelectionView: DesignReviewSelectableView?

  weak var topLayoutGuide: UILayoutGuide?
  private var recentTopConstraints = [NSLayoutConstraint]()
  private var recentBottomConstraints = [NSLayoutConstraint]()
  private var recentLeftConstraints = [NSLayoutConstraint]()
  private var recentRightConstraints = [NSLayoutConstraint]()

  // MARK: - Spec views

  private lazy var leftSpecView: DesignReviewSpecView = {
    let view = DesignReviewSpecView()
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  private lazy var rightSpecView: DesignReviewSpecView = {
    let view = DesignReviewSpecView()
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  private lazy var topSpecView: DesignReviewSpecView = {
    let view = DesignReviewSpecView()
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  private lazy var bottomSpecView: DesignReviewSpecView = {
    let view = DesignReviewSpecView()
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  // MARK: - Init

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(containerView: DesignReviewContainerView?,
       borderColor: UIColor = .white,
       borderWidth: CGFloat = .extraExtraSmall,
       selectableStyle: SelectableStyle = .solid) {
    super.init(borderColor: borderColor, borderWidth: borderWidth, selectableStyle: selectableStyle)

    self.containerView = containerView

    clipsToBounds = false
  }

  func refreshLayoutContents() {
    setNeedsDisplay()

    let primaryFrame = primaryView?.convert(primaryView?.bounds ?? .zero, to: containerView) ?? .zero
    let secondaryFrame = secondaryView?.convert(secondaryView?.bounds ?? .zero, to: containerView) ?? .zero
    let specs = DesignReviewViewModel.specs(between: primaryFrame, and: secondaryFrame, in: bounds)

    if specs.shouldHideSpec(for: .top) {
      topSpecView.removeFromSuperview()
    } else {
      topSpecView.updateSpec(specs.top)
      recentTopConstraints.forEach({ $0.isActive = false })
      addSpecViewToContainer(topSpecView, side: .top)
    }

    if specs.shouldHideSpec(for: .bottom) {
      bottomSpecView.removeFromSuperview()
    } else {
      bottomSpecView.updateSpec(specs.bottom)
      recentBottomConstraints.forEach({ $0.isActive = false })
      addSpecViewToContainer(bottomSpecView, side: .bottom)
    }

    if specs.shouldHideSpec(for: .left) {
      leftSpecView.removeFromSuperview()
    } else {
      leftSpecView.updateSpec(specs.left)
      recentLeftConstraints.forEach({ $0.isActive = false })
      addSpecViewToContainer(leftSpecView, side: .left)
    }

    if specs.shouldHideSpec(for: .right) {
      rightSpecView.removeFromSuperview()
    } else {
      rightSpecView.updateSpec(specs.right)
      recentRightConstraints.forEach({ $0.isActive = false })
      addSpecViewToContainer(rightSpecView, side: .right)
    }
  }

  // what the actual hell have you done...

  private func addSpecViewToContainer(_ specView: UIView, side: Specs.Side) {
    guard let containerView = containerView else { return }

    containerView.addSubview(specView)

    switch side {
    case .top:
      guard let primarySelectionView = primarySelectionView,
        let secondarySelectionView = secondarySelectionView else {
          return
      }

      if let previous = self.topLayoutGuide {
        containerView.removeLayoutGuide(previous)
        self.topLayoutGuide = nil
      }

      let layoutGuide = UILayoutGuide()
      containerView.addLayoutGuide(layoutGuide)

      let primaryFrame = primaryView?.convert(primaryView?.bounds ?? .zero, to: containerView) ?? .zero
      let secondaryFrame = secondaryView?.convert(secondaryView?.bounds ?? .zero, to: containerView) ?? .zero

      if secondaryFrame.minY > primaryFrame.minY {
        NSLayoutConstraint.activate([
          layoutGuide.topAnchor.constraint(equalTo: primarySelectionView.topAnchor),
          layoutGuide.bottomAnchor.constraint(equalTo: secondarySelectionView.topAnchor)
        ])
      } else {
        NSLayoutConstraint.activate([
          layoutGuide.topAnchor.constraint(equalTo: secondarySelectionView.topAnchor),
          layoutGuide.bottomAnchor.constraint(equalTo: primarySelectionView.topAnchor)
        ])
      }

      if secondaryFrame.minX > primaryFrame.minX {
        layoutGuide.leadingAnchor.constraint(equalTo: primarySelectionView.leadingAnchor).isActive = true
      } else {
        layoutGuide.leadingAnchor.constraint(equalTo: secondarySelectionView.leadingAnchor).isActive = true
      }

      if secondaryFrame.maxX > primaryFrame.maxX {
        layoutGuide.trailingAnchor.constraint(equalTo: primarySelectionView.trailingAnchor).isActive = true
      } else {
        layoutGuide.trailingAnchor.constraint(equalTo: secondarySelectionView.trailingAnchor).isActive = true
      }

      self.topLayoutGuide = layoutGuide

      recentTopConstraints = [
        specView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
        specView.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor)]
      NSLayoutConstraint.activate(recentTopConstraints)
    case .bottom:
      guard let secondarySelectionView = secondarySelectionView else { return }

      let primaryFrame = primaryView?.convert(primaryView?.bounds ?? .zero, to: containerView) ?? .zero
      let secondaryFrame = secondaryView?.convert(secondaryView?.bounds ?? .zero, to: containerView) ?? .zero

      let topBaseAnchor: NSLayoutYAxisAnchor
      if primaryFrame.maxY > secondaryFrame.maxY {
        topBaseAnchor = secondarySelectionView.bottomAnchor
      } else {
        topBaseAnchor = primarySelectionView?.bottomAnchor ?? secondarySelectionView.bottomAnchor
      }

      recentBottomConstraints = [
        specView.topAnchor.constraint(equalTo: topBaseAnchor),
        specView.centerXAnchor.constraint(equalTo: secondarySelectionView.centerXAnchor)]
      NSLayoutConstraint.activate(recentBottomConstraints)
    case .left:
      guard let secondarySelectionView = secondarySelectionView else { return }

      let primaryFrame = primaryView?.convert(primaryView?.bounds ?? .zero, to: containerView) ?? .zero
      let secondaryFrame = secondaryView?.convert(secondaryView?.bounds ?? .zero, to: containerView) ?? .zero

      let trailingBaseAnchor: NSLayoutXAxisAnchor
      if secondaryFrame.minX > primaryFrame.minX {
        trailingBaseAnchor = secondarySelectionView.leadingAnchor
      } else {
        trailingBaseAnchor = primarySelectionView?.leadingAnchor ?? secondarySelectionView.leadingAnchor
      }

      let trailing = specView.trailingAnchor.constraint(equalTo: trailingBaseAnchor)
      trailing.priority = UILayoutPriority(999)

      let leading = specView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor)
      leading.priority = .required

      let centerYBaseAnchor: NSLayoutYAxisAnchor
      if primaryFrame.contains(secondaryFrame) {
        centerYBaseAnchor = secondarySelectionView.centerYAnchor
      } else if secondaryFrame.contains(primaryFrame) {
        centerYBaseAnchor = primarySelectionView?.centerYAnchor ?? secondarySelectionView.centerYAnchor
      } else if primaryFrame.height > secondaryFrame.height {
        centerYBaseAnchor = secondarySelectionView.centerYAnchor
      } else {
        centerYBaseAnchor = primarySelectionView?.centerYAnchor ?? secondarySelectionView.centerYAnchor
      }

      recentLeftConstraints = [
        leading,
        trailing,
        specView.centerYAnchor.constraint(equalTo: centerYBaseAnchor)]
      NSLayoutConstraint.activate(recentLeftConstraints)
    case .right:
      guard let secondarySelectionView = secondarySelectionView else { return }

      let primaryFrame = primaryView?.convert(primaryView?.bounds ?? .zero, to: containerView) ?? .zero
      let secondaryFrame = secondaryView?.convert(secondaryView?.bounds ?? .zero, to: containerView) ?? .zero

      let leadingBaseAnchor: NSLayoutXAxisAnchor
      if secondaryFrame.maxX > primaryFrame.maxX {
        leadingBaseAnchor = primarySelectionView?.trailingAnchor ?? secondarySelectionView.trailingAnchor
      } else {
        leadingBaseAnchor = secondarySelectionView.trailingAnchor
      }

      let leading = specView.leadingAnchor.constraint(equalTo: leadingBaseAnchor)
      leading.priority = UILayoutPriority(999)

      let trailing = specView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor)
      trailing.priority = .required

      let centerYBaseAnchor: NSLayoutYAxisAnchor
      if primaryFrame.contains(secondaryFrame) {
        centerYBaseAnchor = secondarySelectionView.centerYAnchor
      } else if secondaryFrame.contains(primaryFrame) {
        centerYBaseAnchor = primarySelectionView?.centerYAnchor ?? secondarySelectionView.centerYAnchor
      } else if primaryFrame.height > secondaryFrame.height {
        centerYBaseAnchor = secondarySelectionView.centerYAnchor
      } else {
        centerYBaseAnchor = primarySelectionView?.centerYAnchor ?? secondarySelectionView.centerYAnchor
      }

      recentRightConstraints = [
        leading,
        trailing,
        specView.centerYAnchor.constraint(equalTo: centerYBaseAnchor)]
      NSLayoutConstraint.activate(recentRightConstraints)
    }
  }
}
