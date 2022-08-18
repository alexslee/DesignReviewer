//
//  File.swift
//  
//
//  Created by Alexander Lee on 2022-08-18.
//

import Foundation
import SwiftUI

class SpuddleOptionsCoordinator: NSObject, DesignReviewCoordinatorProtocol {
  var children = [DesignReviewCoordinatorProtocol]()

  var coordinatorID = UUID()

  var parent: DesignReviewCoordinatorProtocol?

  private let viewModel: SpuddleViewModel
  private let optionsViewModel: SpuddleOptionsModifierViewModel
  private let router: SpuddleRouter
  private let changeHandler: ((Any) -> Void)?

  init(viewModel: SpuddleViewModel,
       optionsViewModel: SpuddleOptionsModifierViewModel,
       router: SpuddleRouter,
       changeHandler: ((Any) -> Void)?) {
    self.viewModel = viewModel
    self.optionsViewModel = optionsViewModel
    self.router = router
    self.changeHandler = changeHandler
  }

  func start() {
    let spuddle = Spuddle(
      viewModel: viewModel,
      view: { [weak self] in
        if let self = self {
          SpuddleOptionsModifierView(viewModel: self.optionsViewModel)
        } else {
          EmptyView()
        }
      }, backgroundView: {
        LinearGradient(colors: [.black.opacity(0.7), .clear], startPoint: .bottom, endPoint: .top)
      })

    viewModel.coordinator = self
    optionsViewModel.dismissHandler = { [weak self] in
      self?.dismissHandler()
    }
    router.present(spuddle)
  }

  func dismissHandler() {
    router.dismiss()
    finish()
  }
}
