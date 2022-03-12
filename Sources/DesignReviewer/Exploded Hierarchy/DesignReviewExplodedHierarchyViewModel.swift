//
//  DesignReviewExplodedHierarchyViewModel.swift
//  
//
//  Created by Alex Lee on 3/8/22.
//

import Foundation

class DesignReviewExplodedHierarchyViewModel {
  weak var coordinator: DesignReviewInspectorCoordinator?
  let rootReviewable: DesignReviewable

  init(coordinator: DesignReviewInspectorCoordinator?, rootReviewable: DesignReviewable) {
    self.coordinator = coordinator
    self.rootReviewable = rootReviewable
  }

  func inspect(_ reviewable: DesignReviewable) {
    coordinator?.presentDesignReview(for: reviewable)
  }
}
