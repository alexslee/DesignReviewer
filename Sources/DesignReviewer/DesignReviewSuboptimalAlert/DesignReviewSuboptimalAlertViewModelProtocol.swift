//
//  DesignReviewSuboptimalAlertViewModelProtocol.swift
//  
//
//  Created by Alex Lee on 3/13/22.
//

import Foundation

protocol DesignReviewSuboptimalAlertViewModelProtocol {
  var title: String { get }
  var subtitle: String? { get }
  var onOptionChosen: ((Any) -> Void)? { get }
  var coordinator: DesignReviewSuboptimalAlertCoordinator? { get set }
}

class DesignReviewSuboptimalAlertTextViewModel: DesignReviewSuboptimalAlertViewModelProtocol {
  private(set) var title: String
  private(set) var subtitle: String?

  private(set) var initialValue: String

  private(set) var onOptionChosen: ((Any) -> Void)?

  weak var coordinator: DesignReviewSuboptimalAlertCoordinator?

  init(title: String,
       subtitle: String?,
       initialValue: String,
       onOptionChosen: ((Any) -> Void)?) {
    self.title = title
    self.subtitle = subtitle
    self.initialValue = initialValue
    self.onOptionChosen = onOptionChosen
  }
}

class DesignReviewSuboptimalAlertOptionsViewModel: DesignReviewSuboptimalAlertViewModelProtocol {
  private(set) var title: String
  private(set) var subtitle: String?

  private(set) var options: [DesignReviewAttributeOptionSelectable]
  private(set) var initialOption: DesignReviewAttributeOptionSelectable?

  private(set) var onOptionChosen: ((Any) -> Void)?

  weak var coordinator: DesignReviewSuboptimalAlertCoordinator?

  init(title: String,
       subtitle: String?,
       options: [DesignReviewAttributeOptionSelectable],
       initialOption: DesignReviewAttributeOptionSelectable?,
       onOptionChosen: ((Any) -> Void)?) {
    self.title = title
    self.subtitle = subtitle
    self.options = options
    self.initialOption = initialOption
    self.onOptionChosen = onOptionChosen
  }
}
