//
//  DesignReviewSuboptimalAlertController.swift
//  
//
//  Created by Alex Lee on 3/11/22.
//

import UIKit

/// Represents a selectable option for mutable attributes that can be displayed in an alert (currently,
/// limited to internally defined enum attributes).
public protocol DesignReviewAttributeOptionSelectable {
  /// Name that will be displayed in the table entry for the option.
  var displayName: String { get }
}

protocol DesignReviewSuboptimalAlertViewModelProtocol {
  var title: String { get }
  var subtitle: String? { get }

  var onOptionChosen: ((DesignReviewAttributeOptionSelectable) -> Void)? { get }
}

struct DesignReviewSuboptimalAlertOptionsViewModel: DesignReviewSuboptimalAlertViewModelProtocol {
  private(set) var title: String
  private(set) var subtitle: String?

  private(set) var options: [DesignReviewAttributeOptionSelectable]
  private(set) var initialOption: DesignReviewAttributeOptionSelectable?

  private(set) var onOptionChosen: ((DesignReviewAttributeOptionSelectable) -> Void)?
}

class DesignReviewSuboptimalAlertViewController: UIViewController {
  private lazy var suboptimalAlertView: DesignReviewSuboptimalAlertView = {
    let view = DesignReviewSuboptimalAlertView(viewModel: viewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.okayButton.addTarget(self, action: #selector(okayDokay), for: .touchUpInside)

    return view
  }()

  private let viewModel: DesignReviewSuboptimalAlertViewModelProtocol

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(viewModel: DesignReviewSuboptimalAlertViewModelProtocol) {
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)

    modalPresentationStyle = .overCurrentContext
    modalTransitionStyle = .crossDissolve
    view.backgroundColor = .black.withAlphaComponent(0.5)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(suboptimalAlertView)

    NSLayoutConstraint.activate([
      suboptimalAlertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      suboptimalAlertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

      // large screen affordances
      suboptimalAlertView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: .large),
      suboptimalAlertView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -.large),
      suboptimalAlertView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: .large),
      suboptimalAlertView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                  constant: -.large)
    ])
  }

  @objc private func okayDokay() {
    if let newOption = suboptimalAlertView.selectedOption {
      viewModel.onOptionChosen?(newOption)
    }

    dismiss(animated: true, completion: nil)
  }
}
