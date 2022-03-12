//
//  DesignReviewSuboptimalAlertView.swift
//  
//
//  Created by Alex Lee on 3/12/22.
//

import Foundation
import UIKit

class DesignReviewSuboptimalAlertView: UIView {
  private lazy var containerStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.distribution = .fill
    stack.alignment = .fill
    stack.spacing = .extraSmall
    stack.translatesAutoresizingMaskIntoConstraints = false

    return stack
  }()

  lazy var okayButton: DesignReviewSolidButton = {
    let button = DesignReviewSolidButton(buttonText: "Aight")
    button.translatesAutoresizingMaskIntoConstraints = false

    button.heightAnchor.constraint(equalToConstant: 52).isActive = true
    return button
  }()

  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .body
    return label
  }()

  private(set) lazy var tableView: UITableView = {
    let view = UITableView(frame: .zero, style: .plain)
    view.backgroundColor = .background
    view.dataSource = self
    view.delegate = self

    view.estimatedRowHeight = .extraExtraLarge
    view.estimatedSectionFooterHeight = 0
    view.estimatedSectionHeaderHeight = 0

    view.keyboardDismissMode = .interactive

    view.rowHeight = UITableView.automaticDimension
    view.sectionFooterHeight = 0
    view.sectionHeaderHeight = 0

    view.translatesAutoresizingMaskIntoConstraints = false

    view.register(DesignReviewInspectorTableViewCell.self,
                  forCellReuseIdentifier: DesignReviewInspectorTableViewCell.reuseIdentifier)

    return view
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .header
    return label
  }()

  private lazy var titleStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.distribution = .equalCentering
    stack.spacing = .extraSmall
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.isLayoutMarginsRelativeArrangement = true

    stack.layoutMargins = UIEdgeInsets(top: 0, left: .extraSmall, bottom: 0, right: .extraSmall)

    return stack
  }()

  private let viewModel: DesignReviewSuboptimalAlertViewModelProtocol
  private(set) var selectedOption: DesignReviewAttributeOptionSelectable?

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(viewModel: DesignReviewSuboptimalAlertViewModelProtocol) {
    self.viewModel = viewModel
    super.init(frame: .zero)

    backgroundColor = .background
    layer.cornerRadius = .small

    subtitleLabel.text = viewModel.subtitle
    subtitleLabel.isHidden = viewModel.subtitle == nil
    titleLabel.text = viewModel.title

    let hairline = DesignReviewHairlineView(withDirection: .horizontal)

    addSubview(containerStackView)

    titleStackView.addArrangedSubview(titleLabel)
    titleStackView.addArrangedSubview(hairline)

    containerStackView.addArrangedSubview(titleStackView)
    containerStackView.addArrangedSubview(subtitleLabel)

    let insets = UIEdgeInsets(top: .extraSmall, left: 0, bottom: .extraSmall, right: 0)
    NSLayoutConstraint.activate(containerStackView.constraints(toView: self, withInsets: insets))

    setupAlertContents()
  }

  private func setupAlertContents() {
    if viewModel is DesignReviewSuboptimalAlertOptionsViewModel {
      containerStackView.addArrangedSubview(tableView)

      tableView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true

      let maxHeight = tableView.heightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.heightAnchor)
      maxHeight.priority = .required
      maxHeight.isActive = true

      let idealHeight = tableView.heightAnchor.constraint(
        equalToConstant: DesignReviewSuboptimalAlertView.tableCellHeight * CGFloat(optionsViewModel?.options.count ?? 0))
      idealHeight.priority = UILayoutPriority(999)
      idealHeight.isActive = true

      containerStackView.addArrangedSubview(okayButton)
    }
  }
}

// MARK: - UITableViewDataSource

extension DesignReviewSuboptimalAlertView: UITableViewDataSource {
  static let tableCellHeight: CGFloat = .extraLarge

  private var optionsViewModel: DesignReviewSuboptimalAlertOptionsViewModel? {
    viewModel as? DesignReviewSuboptimalAlertOptionsViewModel
  }

  func numberOfSections(in tableView: UITableView) -> Int { 1 }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let optionsViewModel = optionsViewModel else { return 0 }
    return optionsViewModel.options.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let optionsViewModel = optionsViewModel,
      indexPath.row < optionsViewModel.options.count,
      let cell = tableView.dequeueReusableCell(
        withIdentifier: DesignReviewInspectorTableViewCell.reuseIdentifier,
        for: indexPath) as? DesignReviewInspectorTableViewCell else {
      return tableView.emptyCell(for: indexPath)
    }

    cell.textLabel?.text = optionsViewModel.options[indexPath.row].displayName

    return cell
  }

  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { true }
}

// MARK: - UITableViewDelegate

extension DesignReviewSuboptimalAlertView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let optionsViewModel = optionsViewModel,
      indexPath.row < optionsViewModel.options.count else {
      return
    }

    selectedOption = optionsViewModel.options[indexPath.row]
  }
}

