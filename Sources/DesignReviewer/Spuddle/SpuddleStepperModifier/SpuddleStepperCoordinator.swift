//
//  SpuddleCoordinator.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import SwiftUI
import UIKit

class SpuddleRouter {
  private weak var viewController: UIViewController?
  private var spuddle: Spuddle?

  init(viewController: UIViewController) {
    self.viewController = viewController
  }

  func present(_ spuddle: Spuddle) {
    self.spuddle = spuddle
    self.viewController?.present(spuddle)
  }

  func dismiss() {
    spuddle?.dismiss()
  }
}

class SpuddleStepperCoordinator: NSObject, DesignReviewCoordinatorProtocol {
  var children = [DesignReviewCoordinatorProtocol]()

  var coordinatorID = UUID()

  var parent: DesignReviewCoordinatorProtocol?

  private let viewModel: SpuddleViewModel
  private let stepperViewModel: SpuddleStepperModifierViewModel
  private let router: SpuddleRouter
  private let changeHandler: ((Any) -> Void)?

  init(viewModel: SpuddleViewModel,
       stepperViewModel: SpuddleStepperModifierViewModel,
       router: SpuddleRouter,
       changeHandler: ((Any) -> Void)?) {
    self.viewModel = viewModel
    self.stepperViewModel = stepperViewModel
    self.router = router
    self.changeHandler = changeHandler
  }

  func start() {
    let spuddle = Spuddle(
      viewModel: viewModel,
      view: { [weak self] in
        if let self = self {
          SpuddleStepperModiferView(viewModel: self.stepperViewModel)
        } else {
          EmptyView()
        }
      }, backgroundView: {
        LinearGradient(colors: [.black.opacity(0.7), .clear], startPoint: .bottom, endPoint: .top)
      })

    viewModel.coordinator = self

    stepperViewModel.dismissHandler = { [weak self] in
      self?.dismissHandler()
    }

    router.present(spuddle)
  }

  func dismissHandler() {
    router.dismiss()
    finish()
  }
}
