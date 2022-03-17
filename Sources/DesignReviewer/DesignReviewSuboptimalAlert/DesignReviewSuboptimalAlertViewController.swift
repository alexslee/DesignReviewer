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

class DesignReviewSuboptimalAlertViewController: UIViewController {
  private lazy var suboptimalAlertView: DesignReviewSuboptimalAlertView = {
    let view = DesignReviewSuboptimalAlertView(viewModel: viewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.okayButton.addTarget(self, action: #selector(okayDokay), for: .touchUpInside)
    view.notOkayButton.addTarget(self, action: #selector(thanksButNoThanks), for: .touchUpInside)

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

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    viewModel.coordinator?.finish()
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

  @objc private func thanksButNoThanks() {
    if let viewModel = viewModel as? DesignReviewSuboptimalAlertOptionsViewModel,
       let initialOption = viewModel.initialOption {
      viewModel.onOptionChosen?(initialOption)
    } else if let viewModel = viewModel as? DesignReviewSuboptimalAlertTextViewModel {
      viewModel.onOptionChosen?(viewModel.initialValue)
    }

    resignFirstResponder()

    dismiss(animated: true, completion: nil)
  }
}

extension DesignReviewSuboptimalAlertViewController: DesignReviewSuboptimalAlertViewDelegate {
  func alertView(_ alertView: DesignReviewSuboptimalAlertView, valueDidChange newValue: Any?) {}
}
