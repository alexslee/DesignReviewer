//
//  DesignReviewViewModel.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import os.log
import UIKit

/// Represents the spacing between two `CGRect`s on each side (top, bottom, left, right).
struct Specs {
  enum Side {
    case top, left, bottom, right

    var labelled: String {
      switch self {
      case .top:
        return "T"
      case .left:
        return "L"
      case .bottom:
        return "B"
      case .right:
        return "R"
      }
    }
  }

  let top: CGFloat
  let left: CGFloat
  let bottom: CGFloat
  let right: CGFloat

  func shouldHideSpec(for side: Side) -> Bool {
    switch side {
    case .top:
      return top.roundedForSpecString() <= 0.00
    case .left:
      return left.roundedForSpecString() <= 0.00
    case .bottom:
      return bottom.roundedForSpecString() <= 0.00
    case .right:
      return right.roundedForSpecString() <= 0.00
    }
  }
}

class DesignReviewViewModel {
  private(set) var reviewables = [DesignReviewable]()

  weak var coordinator: DesignReviewCoordinator?
  var selectedReviewableIndices = [Int]()

  var recalculateSelectionBorders: (() -> Void)?
  var toggleHUDVisibility: ((_ isVisible: Bool) -> Void)?

  func refreshSelectionBorders() {
    recalculateSelectionBorders?()
  }

  func startDesignReview() {
    guard let reviewableIndex = selectedReviewableIndices.last, reviewableIndex < reviewables.count else {
      os_log("Error: tried to start a design review, but no valid index was found")
      return
    }

    coordinator?.presentDesignReview(for: reviewables[reviewableIndex])
  }

  func updateReviewables() {
    reviewables = parse(coordinator?.appWindow)
    reviewables.reverse()
  }

  func updateSelectedIndices(index: Int, isPanning: Bool) {
    if !selectedReviewableIndices.isEmpty, isPanning {
      selectedReviewableIndices.removeLast()
    } else if selectedReviewableIndices.count > 1 {
      selectedReviewableIndices.removeFirst()
    }

    selectedReviewableIndices.append(index)
  }
}

// MARK: - Helpers

extension DesignReviewViewModel {
  /// Recursively extracts all reviewable content from the given container
  private func parse(_ reviewableContainer: DesignReviewable?) -> [DesignReviewable] {
    var newReviewables = [DesignReviewable]()

    for subReviewable in reviewableContainer?.subReviewables ?? [] {
      if subReviewable.isOnScreen {
        newReviewables.append(subReviewable)
      }

      if subReviewable.subReviewables.isEmpty { continue }

      newReviewables.append(contentsOf: parse(subReviewable))
    }

    return newReviewables
  }
}

// MARK: - Distance calculation

extension DesignReviewViewModel {
  /// Constructs the `Specs` representing the space between each corresponding side of two given `CGRect`s.
  static func specs(between rect1: CGRect, and rect2: CGRect, in bounds: CGRect) -> Specs {
    let (left, right) = horizontalSpecs(between: rect1, and: rect2, in: bounds)
    let (top, bottom) = verticalSpecs(between: rect1, and: rect2, in: bounds)

    return Specs(top: top, left: left, bottom: bottom, right: right)
  }

  /// Calculates the horizontal (left + right) spaces between the corresponding sides of two given `CGRect`s.
  private static func horizontalSpecs(between rect1: CGRect,
                                      and rect2: CGRect,
                                      in bounds: CGRect) -> (left: CGFloat, right: CGFloat) {
    var left: CGFloat = 0
    var right: CGFloat = 0

    if rect1.minX == rect2.minX, rect1.maxX == rect2.maxX {
      left = 0
      right = 0
    } else if rect1.minX >= rect2.minX, rect1.maxX <= rect2.maxX {
      // rect1 entirely inside rect2
      left = rect1.minX - rect2.minX
      right = rect2.maxX - rect1.maxX
    } else if rect1.minX <= rect2.minX, rect1.maxX >= rect2.maxX {
      // rect2 entirely inside rect1
      left = rect2.minX - rect1.minX
      right = rect1.maxX - rect2.maxX
    } else {
      left = abs(rect1.origin.x - rect2.origin.x)
      right = abs((rect1.origin.x + rect1.size.width) - (rect2.origin.x + rect2.size.width))
    }

    return (left, right)
  }

  /// Calculates the vertical (top + bottom) spaces between the corresponding sides of two given `CGRect`s.
  private static func verticalSpecs(between rect1: CGRect,
                                    and rect2: CGRect,
                                    in bounds: CGRect) -> (top: CGFloat, bottom: CGFloat) {
    var top: CGFloat = 0
    var bottom: CGFloat = 0

    if rect1.minY == rect2.minY, rect1.maxY == rect2.maxY {
      // rects are identical
      top = 0
      bottom = 0
    } else if rect1.minY >= rect2.minY, rect1.maxY <= rect2.maxY {
      // rect1 entirely inside rect2
      top = rect1.minY - rect2.minY
      bottom = rect2.maxY - rect1.maxY
    } else if rect1.minY <= rect2.minY, rect1.maxY >= rect2.maxY {
      // rect2 entirely inside rect1
      top = rect2.minY - rect1.minY
      bottom = rect1.maxY - rect2.maxY
    } else {
      top = abs(rect1.origin.y - rect2.origin.y)
      bottom = abs((rect1.origin.y + rect1.size.height) - (rect2.origin.y + rect2.size.height))
    }

    return (top, bottom)
  }
}
