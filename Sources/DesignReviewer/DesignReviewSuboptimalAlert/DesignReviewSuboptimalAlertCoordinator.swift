//
//  DesignReviewSuboptimalAlertCoordinator.swift
//  
//
//  Created by Alex Lee on 3/12/22.
//

import Foundation
import UIKit

class DesignReviewSuboptimalAlertRouter {
  private weak var viewController: UIViewController?

  init(viewController: UIViewController) {
    self.viewController = viewController
  }

  func present(_ viewController: UIViewController) {
    self.viewController?.present(viewController, animated: true, completion: nil)
  }
}

class DesignReviewSuboptimalAlertCoordinator: DesignReviewCoordinatorProtocol {
  let coordinatorID = UUID()
  var children = [DesignReviewCoordinatorProtocol]()
  weak var parent: DesignReviewCoordinatorProtocol?

  private let router: DesignReviewSuboptimalAlertRouter
  private let viewModel: DesignReviewSuboptimalAlertViewModelProtocol

  init(viewModel: DesignReviewSuboptimalAlertViewModelProtocol,
       router: DesignReviewSuboptimalAlertRouter) {
    self.router = router
    self.viewModel = viewModel
  }

  func start() {
    let viewController = DesignReviewSuboptimalAlertViewController(viewModel: viewModel)
    router.present(viewController)
  }
}
