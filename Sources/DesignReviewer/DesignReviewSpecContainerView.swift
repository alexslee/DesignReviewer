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
  private var pathViews = [UIView]()

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

    for view in pathViews {
      view.removeFromSuperview()
    }

    pathViews = []

    if specs.shouldHideSpec(for: .top) {
      topSpecView.removeFromSuperview()
    } else {
      topSpecView.updateSpec(specs.top)
      recentTopConstraints.forEach({ $0.isActive = false })
      addSpecViewToContainerV2(topSpecView, side: .top)
    }

    if specs.shouldHideSpec(for: .bottom) {
      bottomSpecView.removeFromSuperview()
    } else {
      bottomSpecView.updateSpec(specs.bottom)
      recentBottomConstraints.forEach({ $0.isActive = false })
      addSpecViewToContainerV2(bottomSpecView, side: .bottom)
    }

    if specs.shouldHideSpec(for: .left) {
      leftSpecView.removeFromSuperview()
    } else {
      leftSpecView.updateSpec(specs.left)
      recentLeftConstraints.forEach({ $0.isActive = false })
      addSpecViewToContainerV2(leftSpecView, side: .left)
    }

    if specs.shouldHideSpec(for: .right) {
      rightSpecView.removeFromSuperview()
    } else {
      rightSpecView.updateSpec(specs.right)
      recentRightConstraints.forEach({ $0.isActive = false })
      addSpecViewToContainerV2(rightSpecView, side: .right)
    }
  }

  // what the actual hell have you done...

  private func addSpecViewToContainerV2(_ specView: UIView, side: Specs.Side) {
    guard let containerView = containerView else { return }

    containerView.addSubview(specView)

    guard let primaryFrame = primaryView?.convert(primaryView?.bounds ?? .zero, to: containerView),
          let secondaryFrame = secondaryView?.convert(secondaryView?.bounds ?? .zero, to: containerView) else {
        return
    }

    var centerPoint: CGPoint?
    var path: UIBezierPath?

    /*
     Figure out where to place the spec label depending on which sides we are comparing, and prepare the path for the
     line that will be drawn between the sides.
     */
    switch side {
    case .top:
      let topOfPrimary = CGPoint(x: primaryFrame.origin.x + primaryFrame.size.width / 2, y: primaryFrame.origin.y)

      if isFrame(secondaryFrame, inside: primaryFrame) {
        // secondary view is entirely inside the primary view
        let topOfSecondary = CGPoint(x: primaryFrame.origin.x + primaryFrame.size.width / 2, y: secondaryFrame.origin.y)
        centerPoint = CGPoint(x: topOfSecondary.x, y: topOfPrimary.y + ((topOfSecondary.y - topOfPrimary.y) / 2))

        path = makePath(from: topOfPrimary, to: topOfSecondary)
      } else if primaryFrame.origin.y + primaryFrame.size.height < secondaryFrame.origin.y {
        // primary view is entirely above the secondary view
        let bottomOfPrimary = CGPoint(x: primaryFrame.origin.x + primaryFrame.size.width / 2,
                                      y: primaryFrame.origin.y + primaryFrame.size.height)
        let topOfSecondary = CGPoint(x: primaryFrame.origin.x + primaryFrame.size.width / 2, y: secondaryFrame.origin.y)
        centerPoint = CGPoint(x: topOfSecondary.x, y: bottomOfPrimary.y + ((topOfSecondary.y - bottomOfPrimary.y) / 2))

        path = makePath(from: bottomOfPrimary, to: topOfSecondary)
      } else {
        let topOfSecondary = CGPoint(x: primaryFrame.origin.x + primaryFrame.size.width / 2, y: secondaryFrame.origin.y)
        centerPoint = CGPoint(x: topOfSecondary.x, y: topOfPrimary.y + ((topOfSecondary.y - topOfPrimary.y) / 2))

        path = makePath(from: topOfPrimary, to: topOfSecondary)
      }

      guard let center = centerPoint else { return }

      recentTopConstraints = [
        specView.centerXAnchor.constraint(equalTo: containerView.leadingAnchor, constant: center.x),
        specView.centerYAnchor.constraint(equalTo: containerView.topAnchor, constant: center.y)]
      NSLayoutConstraint.activate(recentTopConstraints)
    case .left:
      let leftOfPrimary = CGPoint(x: primaryFrame.origin.x, y: primaryFrame.origin.y + primaryFrame.size.height / 2)

      if isFrame(primaryFrame, inside: secondaryFrame) {
        // primary view is entirely inside the secondary view
        let leftOfSecondary = CGPoint(x: secondaryFrame.origin.x, y: leftOfPrimary.y)
        centerPoint = CGPoint(x: leftOfSecondary.x + ((leftOfPrimary.x - leftOfSecondary.x) / 2), y: leftOfSecondary.y)

        path = makePath(from: leftOfSecondary, to: leftOfPrimary)
      } else if primaryFrame.origin.x + primaryFrame.size.width < secondaryFrame.origin.x {
        // primary view is entirely left of the secondary view
        let leftOfSecondary = CGPoint(x: secondaryFrame.origin.x, y: leftOfPrimary.y)
        let rightOfPrimary = CGPoint(x: primaryFrame.origin.x + primaryFrame.size.width,
                                     y: primaryFrame.origin.y + primaryFrame.size.height / 2)
        centerPoint = CGPoint(x: rightOfPrimary.x + ((leftOfSecondary.x - rightOfPrimary.x) / 2), y: leftOfSecondary.y)

        path = makePath(from: rightOfPrimary, to: leftOfSecondary)
      } else if isFrame(secondaryFrame, inside: primaryFrame) {
        // secondary view is entirely inside the primary view
        let leftOfSecondary = CGPoint(x: secondaryFrame.origin.x, y: leftOfPrimary.y)
        centerPoint = CGPoint(x: leftOfSecondary.x + ((leftOfPrimary.x - leftOfSecondary.x) / 2), y: leftOfSecondary.y)

        path = makePath(from: leftOfPrimary, to: leftOfSecondary)
      } else if primaryFrame.origin.x > secondaryFrame.origin.x {
        // primary view's left edge is still a bit further right than the left edge of the secondary view
        let leftOfSecondary = CGPoint(x: secondaryFrame.origin.x, y: leftOfPrimary.y)
        centerPoint = CGPoint(x: leftOfSecondary.x + ((leftOfPrimary.x - leftOfSecondary.x) / 2), y: leftOfPrimary.y)

        path = makePath(from: leftOfSecondary, to: leftOfPrimary)
      } else if primaryFrame.origin.x < secondaryFrame.origin.x {
        // primary view is partially, but not entirely, left of the secondary view
        let leftOfSecondary = CGPoint(x: secondaryFrame.origin.x, y: leftOfPrimary.y)
        centerPoint = CGPoint(x: leftOfPrimary.x + ((leftOfSecondary.x - leftOfPrimary.x) / 2), y: leftOfPrimary.y)

        path = makePath(from: leftOfPrimary, to: leftOfSecondary)
      } else {
        let leftOfSecondary = CGPoint(x: secondaryFrame.origin.x, y: leftOfPrimary.y)
        let rightOfPrimary = CGPoint(x: primaryFrame.origin.x + primaryFrame.size.width,
                                     y: primaryFrame.origin.y + primaryFrame.size.height / 2)
        centerPoint = CGPoint(x: leftOfSecondary.x + ((rightOfPrimary.x - leftOfSecondary.x) / 2), y: leftOfSecondary.y)

        path = makePath(from: leftOfSecondary, to: rightOfPrimary)
      }

      guard let center = centerPoint else { return }

      recentLeftConstraints = [
        specView.centerXAnchor.constraint(equalTo: containerView.leadingAnchor, constant: center.x),
        specView.centerYAnchor.constraint(equalTo: containerView.topAnchor, constant: center.y)]
      NSLayoutConstraint.activate(recentLeftConstraints)
    case .bottom:
      let bottomOfPrimary = CGPoint(x: primaryFrame.origin.x + (primaryFrame.size.width / 2), y: primaryFrame.origin.y + primaryFrame.size.height)
      if isFrame(primaryFrame, inside: secondaryFrame) {
        // primary view is entirely inside the secondary view
        let bottomOfSecondary = CGPoint(x: bottomOfPrimary.x, y: secondaryFrame.origin.y + secondaryFrame.size.height)

        centerPoint = CGPoint(x: bottomOfSecondary.x, y: bottomOfPrimary.y + ((bottomOfSecondary.y - bottomOfPrimary.y) / 2))

        path = makePath(from: bottomOfPrimary, to: bottomOfSecondary)
      } else if bottomOfPrimary.y <= secondaryFrame.origin.y {
        // primary view is entirely above the secondary view
        let topOfSecondary = CGPoint(x: bottomOfPrimary.x, y: secondaryFrame.origin.y)
        centerPoint = CGPoint(x: topOfSecondary.x, y: bottomOfPrimary.y + ((topOfSecondary.y - bottomOfPrimary.y) / 2))

        path = makePath(from: bottomOfPrimary, to: topOfSecondary)
      } else if primaryFrame.origin.y > secondaryFrame.origin.y + secondaryFrame.size.height {
        // primary view is entirely below the secondary view
        let bottomOfSecondary = CGPoint(x: bottomOfPrimary.x, y: secondaryFrame.origin.y + secondaryFrame.size.height)
        let topOfPrimary = CGPoint(x: primaryFrame.origin.x + (primaryFrame.size.width / 2), y: primaryFrame.origin.y)
        centerPoint = CGPoint(x: bottomOfSecondary.x, y: bottomOfSecondary.y + ((topOfPrimary.y - bottomOfSecondary.y) / 2))

        path = makePath(from: bottomOfSecondary, to: topOfPrimary)
      } else {
        let bottomOfSecondary = CGPoint(x: bottomOfPrimary.x, y: secondaryFrame.origin.y + secondaryFrame.size.height)

        centerPoint = CGPoint(x: bottomOfSecondary.x, y: bottomOfPrimary.y + ((bottomOfSecondary.y - bottomOfPrimary.y) / 2))

        path = makePath(from: bottomOfPrimary, to: bottomOfSecondary)
      }

      guard let center = centerPoint else { return }

      recentBottomConstraints = [
        specView.centerXAnchor.constraint(equalTo: containerView.leadingAnchor, constant: center.x),
        specView.centerYAnchor.constraint(equalTo: containerView.topAnchor, constant: center.y)]
      NSLayoutConstraint.activate(recentBottomConstraints)
    case .right:
      let rightOfPrimary = CGPoint(x: primaryFrame.origin.x + primaryFrame.size.width,
                                   y: primaryFrame.origin.y + primaryFrame.size.height / 2)
      if isFrame(primaryFrame, inside: secondaryFrame) {
        // primary view is entirely inside the secondary view
        let rightOfSecondary = CGPoint(x: secondaryFrame.origin.x + secondaryFrame.size.width, y: rightOfPrimary.y)
        centerPoint = CGPoint(x: rightOfPrimary.x + ((rightOfSecondary.x - rightOfPrimary.x) / 2), y: rightOfPrimary.y)

        path = makePath(from: rightOfPrimary, to: rightOfSecondary)
      } else if primaryFrame.origin.x >= secondaryFrame.origin.x + secondaryFrame.size.width {
        // primary view is entirely right of the secondary view
        let leftOfPrimary = CGPoint(x: primaryFrame.origin.x, y: primaryFrame.origin.y + primaryFrame.size.height / 2)
        let rightOfSecondary = CGPoint(x: secondaryFrame.origin.x + secondaryFrame.size.width, y: leftOfPrimary.y)
        centerPoint = CGPoint(x: rightOfSecondary.x + ((leftOfPrimary.x - rightOfSecondary.x) / 2), y: leftOfPrimary.y)

        path = makePath(from: rightOfSecondary, to: leftOfPrimary)
      } else if isFrame(secondaryFrame, inside: primaryFrame) {
        // secondary view is entirely inside the primary view
        let rightOfSecondary = CGPoint(x: secondaryFrame.origin.x + secondaryFrame.size.width, y: rightOfPrimary.y)
        centerPoint = CGPoint(x: rightOfSecondary.x + ((rightOfPrimary.x - rightOfSecondary.x) / 2), y: rightOfPrimary.y)

        path = makePath(from: rightOfSecondary, to: rightOfPrimary)
      } else if primaryFrame.origin.x + primaryFrame.size.width < secondaryFrame.origin.x + secondaryFrame.size.width {
        // primary view's right edge is still a bit further left than the right edge of the secondary view
        let rightOfSecondary = CGPoint(x: secondaryFrame.origin.x + secondaryFrame.size.width, y: rightOfPrimary.y)
        centerPoint = CGPoint(x: rightOfPrimary.x + ((rightOfSecondary.x - rightOfPrimary.x) / 2), y: rightOfSecondary.y)

        path = makePath(from: rightOfPrimary, to: rightOfSecondary)
      } else if primaryFrame.origin.x + primaryFrame.size.width > secondaryFrame.origin.x + secondaryFrame.size.width {
        // primary view's right edge is now further right than the right edge of the secondary
        let rightOfSecondary = CGPoint(x: secondaryFrame.origin.x + secondaryFrame.size.width, y: rightOfPrimary.y)
        centerPoint = CGPoint(x: rightOfSecondary.x + ((rightOfPrimary.x - rightOfSecondary.x) / 2), y: rightOfSecondary.y)

        path = makePath(from: rightOfSecondary, to: rightOfPrimary)
      } else {
        // primary view's left edge is partially, but not entirely, right of the secondary view
        let leftOfPrimary = CGPoint(x: primaryFrame.origin.x, y: primaryFrame.origin.y + primaryFrame.size.height / 2)
        let rightOfSecondary = CGPoint(x: secondaryFrame.origin.x + secondaryFrame.size.width, y: leftOfPrimary.y)
        centerPoint = CGPoint(x: leftOfPrimary.x + ((rightOfSecondary.x - leftOfPrimary.x) / 2), y: leftOfPrimary.y)

        path = makePath(from: leftOfPrimary, to: rightOfSecondary)
      }

      guard let center = centerPoint else { return }

      recentRightConstraints = [
        specView.centerXAnchor.constraint(equalTo: containerView.leadingAnchor, constant: center.x),
        specView.centerYAnchor.constraint(equalTo: containerView.topAnchor, constant: center.y)]
      NSLayoutConstraint.activate(recentRightConstraints)
    }

    // lastly, draw the line between the two edges
    if let drawPath = path { addShapeLayer(for: drawPath) }
  }

  // TODO: delete this once proven that the new method is reliable
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

  private func isFrame(_ candidateFrame: CGRect, inside comparisonFrame: CGRect) -> Bool {
    return candidateFrame.origin.x >= comparisonFrame.origin.x &&
    candidateFrame.origin.x + candidateFrame.size.width <= comparisonFrame.origin.x + comparisonFrame.size.width &&
    candidateFrame.origin.y >= comparisonFrame.origin.y &&
    candidateFrame.origin.y + candidateFrame.size.height <= comparisonFrame.origin.y + comparisonFrame.size.height
  }

  // creates the path between two given points, meant to turn into a CAShapeLayer via `addShapeLayer(for:)`
  private func makePath(from start: CGPoint, to end: CGPoint) -> UIBezierPath {
    let retVal = UIBezierPath()

    let isVertical = start.y != end.y

    if isVertical {
      let isStartLessThanEnd = start.y < end.y

      let verticalStart = start.y + (.extraExtraSmall * (isStartLessThanEnd ? 1 : -1))
      let verticalEnd = end.y + (.extraExtraSmall * (isStartLessThanEnd ? -1 : 1))

      retVal.move(to: CGPoint(x: start.x - .extraExtraSmall, y: verticalStart))
      retVal.addLine(to: CGPoint(x: start.x + .extraExtraSmall, y: verticalStart))
      retVal.addLine(to: CGPoint(x: start.x, y: verticalStart))
      retVal.addLine(to: CGPoint(x: end.x, y: verticalEnd))
      retVal.addLine(to: CGPoint(x: end.x - .extraExtraSmall, y: verticalEnd))
      retVal.addLine(to: CGPoint(x: end.x + .extraExtraSmall, y: verticalEnd))
      retVal.addLine(to: CGPoint(x: end.x, y: verticalEnd))
      retVal.addLine(to: CGPoint(x: start.x, y: verticalStart))
    } else {
      let isStartLessThanEnd = start.x < end.x

      let horizontalStart = start.x + (.extraExtraSmall * (isStartLessThanEnd ? 1 : -1))
      let horizontalEnd = end.x + (.extraExtraSmall * (isStartLessThanEnd ? -1 : 1))

      retVal.move(to: CGPoint(x: horizontalStart, y: start.y))
      retVal.addLine(to: CGPoint(x: horizontalStart, y: start.y - .extraExtraSmall))
      retVal.addLine(to: CGPoint(x: horizontalStart, y: start.y + .extraExtraSmall))
      retVal.addLine(to: CGPoint(x: horizontalStart, y: start.y))
      retVal.addLine(to: CGPoint(x: horizontalEnd, y: end.y))
      retVal.addLine(to: CGPoint(x: horizontalEnd, y: end.y - .extraExtraSmall))
      retVal.addLine(to: CGPoint(x: horizontalEnd, y: end.y + .extraExtraSmall))
      retVal.addLine(to: CGPoint(x: horizontalEnd, y: end.y))
      retVal.move(to: CGPoint(x: horizontalStart, y: start.y))
    }

    // the line should end up looking like: |-----(spec view)-----| (or the vertical version, if isVertical was true)
    return retVal
  }

  /// draws the line between the edges of the views to help make it clear which gap the spec refers to
  private func addShapeLayer(for path: UIBezierPath) {
    guard let containerView = containerView else { return }
    let shapeLayer = CAShapeLayer()
    shapeLayer.bounds = containerView.bounds
    shapeLayer.position = containerView.center
    shapeLayer.path = path.cgPath

    shapeLayer.lineWidth = 2
    shapeLayer.borderColor = UIColor.primary3.cgColor
    shapeLayer.fillColor = UIColor.primary3.cgColor
    shapeLayer.strokeColor = UIColor.primary3.cgColor

    let shapeView = UIView()
    shapeView.backgroundColor = .clear
    shapeView.layer.addSublayer(shapeLayer)
    shapeView.translatesAutoresizingMaskIntoConstraints = false

    containerView.addSubview(shapeView)
    NSLayoutConstraint.activate(shapeView.constraints(toView: containerView))
    pathViews.append(shapeView)
  }
}
