//
//  DesignReviewCoordinatorProtocol.swift
//  
//
//  Created by Alex Lee on 3/11/22.
//

import Foundation

protocol DesignReviewCoordinatorProtocol: AnyObject {
  var children: [DesignReviewCoordinatorProtocol] { get set }
  var coordinatorID: UUID { get }
  var parent: DesignReviewCoordinatorProtocol? { get set }

  func finish()
  func removeAllChildren()
  func start()
}

// MARK: - Default implementations

extension DesignReviewCoordinatorProtocol {
  func finish() {
    parent?.removeChild(self)
  }

  func removeAllChildren() {
    children.removeAll()
  }

  private func removeChild(_ child: DesignReviewCoordinatorProtocol) {
    guard let childIndex = children.firstIndex(where: { $0 === child }) else {
      return
    }

    // Clear child-coordinators recursively
    if !child.children.isEmpty {
      child.children
        .filter({ $0 !== child })
        .forEach({ child.removeChild($0) })
    }

    child.parent = nil
    children.remove(at: childIndex)
  }
}
