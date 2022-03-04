//
//  DesignReviewExplodedHierarchyView.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

class DesignReviewExplodedHierarchyView: UIView {
  private(set) var baseReviewable: DesignReviewable

  private(set) var children = [DesignReviewExplodedHierarchyView]()

  /// the container for all of the exploded hierarchy views
  weak var container: DesignReviewExplodedHierarchyContainerView?

  private var clippedToBoundsFrame: CGRect = .zero
  private(set) var convertedFrame: CGRect = .zero

  var depthInHierarchy = 0

  var isCurrentlySelected = false {
    didSet {
      if isCurrentlySelected {
        border.fillColor = UIColor.primary4.withAlphaComponent(0.3).cgColor
        border.strokeColor = UIColor.primary4.cgColor
      } else {
        border.fillColor = UIColor.clear.cgColor
        border.strokeColor = UIColor.monochrome4.cgColor
      }
    }
  }

  /// the view's immediate parent in the exploded hierarchy, if one exists
  weak var parent: DesignReviewExplodedHierarchyView?

  /// the root of the design review. Required for frame conversions.
  private weak var root: UIView?

  private var screenshot: UIImage?

  private let border = CAShapeLayer()

  private lazy var titleView: UIButton = {
      let button = UIButton(type: .custom)
      button.backgroundColor = .white
      button.setTitleColor(.black, for: .normal)
      button.titleLabel?.font = .systemFont(ofSize: 10)
      button.isUserInteractionEnabled = false

      let frame = CGRect(x: clippedToBoundsFrame.origin.x,
                         y: clippedToBoundsFrame.origin.y - 21,
                         width: clippedToBoundsFrame.width,
                         height: 19)
      button.frame = self.convert(frame, from: self.root)
      return button
  }()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(reviewable: DesignReviewable, root: UIView) {
    baseReviewable = reviewable

    super.init(frame: .zero)

    if let view = reviewable as? UIView {
      var hiddenStates = [Bool]()

      for subview in view.subviews {
        hiddenStates.append(subview.isHidden)
        subview.isHidden = true
      }

      screenshot = view.polaroidSelfie()

      for (subviewIndex, subview) in view.subviews.enumerated() {
        subview.isHidden = hiddenStates[subviewIndex]
      }

      // Calling layoutIfNeeded after messing with the visibility above, ensures stack views don't have
      // zero height/width due to hidden subviews when calculating frames.
      view.superview?.layoutIfNeeded()

      convertedFrame = root.convert(view.frame, from: view.superview)

      if let superview = superview, superview.clipsToBounds {
          let frame = superview.bounds.intersection(view.frame)
          self.clippedToBoundsFrame = root.convert(frame, from: superview)
      } else {
          self.clippedToBoundsFrame = root.bounds.intersection(self.convertedFrame)
      }
    }

    self.root = root
    frame = convertedFrame

    let bezierPath = UIBezierPath(rect: self.convert(clippedToBoundsFrame, from: root))
    border.path = bezierPath.cgPath
    border.fillColor = UIColor.clear.cgColor
    border.strokeColor = UIColor.monochrome4.cgColor
    border.lineWidth = 1.0 / UIScreen.main.scale
    layer.addSublayer(border)

    titleView.setTitle("\(type(of: reviewable))", for: .normal)
    titleView.isHidden = true
    addSubview(titleView)

    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTapRevenge)))

    children = reviewable.subReviewables.compactMap { childReviewable in
      let child = DesignReviewExplodedHierarchyView(reviewable: childReviewable, root: root)
      child.parent = self
      return child
    }

    layer.contents = screenshot?.cgImage
  }

  @objc private func tapTapRevenge(_ sender: UITapGestureRecognizer) {
    guard sender.state == .recognized else { return }

    container?.primaryView = self
  }

  func toggleNameVisibility(_ shouldShow: Bool) {
    titleView.isHidden = !shouldShow
  }
}
