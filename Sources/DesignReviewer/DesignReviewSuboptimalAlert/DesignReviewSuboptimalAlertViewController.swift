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
  var onOptionChosen: ((Any) -> Void)? { get }
}

struct DesignReviewSuboptimalAlertTextViewModel: DesignReviewSuboptimalAlertViewModelProtocol {
  private(set) var title: String
  private(set) var subtitle: String?

  private(set) var initialValue: String

  private(set) var onOptionChosen: ((Any) -> Void)?
}

struct DesignReviewSuboptimalAlertOptionsViewModel: DesignReviewSuboptimalAlertViewModelProtocol {
  private(set) var title: String
  private(set) var subtitle: String?

  private(set) var options: [DesignReviewAttributeOptionSelectable]
  private(set) var initialOption: DesignReviewAttributeOptionSelectable?

  private(set) var onOptionChosen: ((Any) -> Void)?
}

class DesignReviewSuboptimalAlertViewController: UIViewController {
  private lazy var suboptimalAlertView: DesignReviewSuboptimalAlertView = {
    let view = DesignReviewSuboptimalAlertView(viewModel: viewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.okayButton.addTarget(self, action: #selector(okayDokay), for: .touchUpInside)

    view.delegate = self

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

  override var canBecomeFirstResponder: Bool {
    viewModel is DesignReviewSuboptimalAlertTextViewModel
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

    if canBecomeFirstResponder {
      becomeFirstResponder()
    }
  }

  @objc private func okayDokay() {
    if let newOption = suboptimalAlertView.selectedOption {
      viewModel.onOptionChosen?(newOption)
    } else if let newText = suboptimalAlertView.textView.text {
      viewModel.onOptionChosen?(newText)
    }

    resignFirstResponder()

    dismiss(animated: true, completion: nil)
  }
}

extension DesignReviewSuboptimalAlertViewController: DesignReviewSuboptimalAlertViewDelegate {
  func alertView(_ alertView: DesignReviewSuboptimalAlertView, valueDidChange newValue: Any?) {
    guard let newValue = newValue else { return }

    viewModel.onOptionChosen?(newValue)
  }
}
