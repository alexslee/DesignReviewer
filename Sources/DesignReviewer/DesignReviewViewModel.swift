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
  }

  let top: CGFloat
  let left: CGFloat
  let bottom: CGFloat
  let right: CGFloat
}

class DesignReviewViewModel {
  private(set) var reviewables = [DesignReviewable]()

  weak var coordinator: DesignReviewCoordinator?
  var selectedReviewableIndices = [Int]()

  var recalculateHighlights: (() -> Void)?
  var toggleHUDVisibility: ((_ isVisible: Bool) -> Void)?

  func refreshHighlights() {
    recalculateHighlights?()
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
  /// Calculates the distance between each corresponding side of two given `CGRect`s.
  static func distance(from: CGRect, to: CGRect, in bounds: CGRect) -> Specs {
    var left: CGFloat = 0
    var right: CGFloat = 0
    var top: CGFloat = 0
    var bottom: CGFloat = 0

    let hSpacing = bounds.width - (from.width + to.width)
    let vSpacing = bounds.height - (from.height + to.height)

    // calculating left + right specs
    if (to.minX == from.minX) && (to.maxX == from.maxX) {
      right = 0
      left = 0
    } else if (from.minX >= to.minX) && (from.maxX <= to.maxX) {
      left = from.minX - to.minX
      right = to.maxX - from.maxX
    } else if (to.minX >= from.minX) && (to.maxX <= from.maxX) {
      left = to.minX - from.minX
      right = from.maxX - to.maxX
    } else if to.minX < from.minX {
      left = 0
      right = hSpacing
    } else {
      left = hSpacing
      right = 0
    }

    if (to.minY == from.minY) && (to.maxY == from.maxY) {
      top = 0
      bottom = 0
    } else if (from.minY >= to.minY) && (from.maxY <= to.maxY) {
      top = from.minY - to.minY
      bottom = to.maxY - from.maxY
    } else if (to.minY >= from.minY) && (to.maxY <= from.maxY) {
      top = to.minY - from.minY
      bottom = from.maxY - to.maxY
    } else if to.minY < from.minY {
      top = 0
      bottom = vSpacing
    } else {
      top = vSpacing
      bottom = 0
    }

    return Specs(top: top, left: left, bottom: bottom, right: right)
  }
}
