//
//  SpuddleWindowManager.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import UIKit

/// Supports multiple windows by maintaining a 1:1 mapping of `UIWindow` to `SpuddlePresentedViewModel`.
class SpuddleWindowManager {
  static let shared = SpuddleWindowManager()

  /// Allows storage of an object type without affecting ARC
  private class Weakified<T>: NSObject where T: AnyObject {
    private(set) weak var pointee: T?

    var isDeallocated: Bool { pointee == nil }

    init(pointee: T) {
      self.pointee = pointee
    }
  }

  private var mappedViewModels = [Weakified<UIWindow>: SpuddlePresentedViewModel]()

  private init() {}

  func viewModel(for window: UIWindow) -> SpuddlePresentedViewModel {
    deleteAsNeeded()
    if let existing = mappedViewModels.first(where: { holder, _ in holder.pointee === window })?.value {
      return existing
    } else {
      return setupNewViewModel(for: window)
    }
  }

  // MARK: - Helpers

  func deleteAsNeeded() {
    mappedViewModels.keys.filter(\.isDeallocated).forEach { key in
      mappedViewModels[key] = nil
    }
  }

  private func setupNewViewModel(for window: UIWindow) -> SpuddlePresentedViewModel {
    let newModel = SpuddlePresentedViewModel()
    let weakWindowReference = Weakified(pointee: window)
    mappedViewModels[weakWindowReference] = newModel

    return newModel
  }
}
