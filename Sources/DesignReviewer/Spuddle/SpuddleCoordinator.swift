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
  private let router: SpuddleRouter
  private let attribute: DesignReviewInspectorAttribute
  private let changeHandler: ((Any) -> Void)?

  init(viewModel: SpuddleViewModel,
       router: SpuddleRouter,
       attribute: DesignReviewInspectorAttribute,
       changeHandler: ((Any) -> Void)?) {
    self.viewModel = viewModel
    self.router = router
    self.attribute = attribute
    self.changeHandler = changeHandler
  }

  func start() {
    let spuddle = Spuddle(
      viewModel: viewModel,
      view: { [weak self] in
        if let self = self {
          let stepperViewModel = SpuddleStepperModifierViewModel(attribute: self.attribute,
                                                                 changeHandler: self.changeHandler,
                                                                 dismissHandler: { [weak self] in
            self?.dismissHandler()
          })
          SpuddleStepperModiferView(viewModel: stepperViewModel)
        } else {
          EmptyView()
        }
      }, backgroundView: {
        LinearGradient(colors: [.black.opacity(0.7), .clear], startPoint: .bottom, endPoint: .top)
      })

    viewModel.coordinator = self
    router.present(spuddle)
  }

  func dismissHandler() {
    router.dismiss()
    finish()
  }
}
