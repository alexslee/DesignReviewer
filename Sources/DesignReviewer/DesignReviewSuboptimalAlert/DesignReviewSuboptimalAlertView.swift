//
//  DesignReviewSuboptimalAlertView.swift
//  
//
//  Created by Alex Lee on 3/12/22.
//

import Foundation
import UIKit

protocol DesignReviewSuboptimalAlertViewDelegate: AnyObject {
  func alertView(_ alertView: DesignReviewSuboptimalAlertView, valueDidChange newValue: Any?)
}

class DesignReviewSuboptimalAlertView: UIView {
  static let tableCellHeight: CGFloat = .extraLarge

  private lazy var buttonStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .fillEqually
    stack.alignment = .fill
    stack.spacing = .extraSmall

    return stack
  }()

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

  lazy var notOkayButton: DesignReviewSolidButton = {
    let button = DesignReviewSolidButton(buttonText: "Nah")

    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .clear
    button.setTitleColor(.primary3, for: .normal)

    button.heightAnchor.constraint(equalToConstant: 52).isActive = true
    return button
  }()

  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .body
    return label
  }()

  private(set) lazy var textView: UITextView = {
    let view = UITextView()
    view.backgroundColor = .monochrome1
    view.font = .body
    view.isEditable = true
    view.isScrollEnabled = true
    view.layer.borderColor = UIColor.monochrome2.cgColor
    view.layer.borderWidth = 1
    view.layer.cornerRadius = .extraExtraSmall
    view.keyboardType = .default
    view.textColor = .monochrome5
    view.translatesAutoresizingMaskIntoConstraints = false

    view.delegate = self

    return view
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
    view.allowsMultipleSelection = false

    view.translatesAutoresizingMaskIntoConstraints = false

    view.register(DesignReviewInspectorTableViewCell.self,
                  forCellReuseIdentifier: DesignReviewInspectorTableViewCell.reuseIdentifier)

    return view
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .header
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()

  private lazy var titleStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.distribution = .equalCentering
    stack.spacing = .extraExtraSmall
    stack.isLayoutMarginsRelativeArrangement = true

    stack.layoutMargins = UIEdgeInsets(top: 0, left: .extraSmall, bottom: 0, right: .extraSmall)

    return stack
  }()

  private let viewModel: DesignReviewSuboptimalAlertViewModelProtocol

  private var optionsViewModel: DesignReviewSuboptimalAlertOptionsViewModel? {
    viewModel as? DesignReviewSuboptimalAlertOptionsViewModel
  }

  private var textViewModel: DesignReviewSuboptimalAlertTextViewModel? {
    viewModel as? DesignReviewSuboptimalAlertTextViewModel
  }

  weak var delegate: DesignReviewSuboptimalAlertViewDelegate?
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

    buttonStackView.addArrangedSubview(okayButton)
    buttonStackView.addArrangedSubview(notOkayButton)

    containerStackView.addArrangedSubview(buttonStackView)
  }

  private func setupAlertContents() {
    if let optionsViewModel = optionsViewModel {
      selectedOption = optionsViewModel.initialOption

      containerStackView.addArrangedSubview(tableView)

      tableView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true

      let maxHeight = tableView.heightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.heightAnchor)
      maxHeight.priority = .required
      maxHeight.isActive = true

      let idealHeight = tableView.heightAnchor.constraint(
        equalToConstant: DesignReviewSuboptimalAlertView.tableCellHeight * CGFloat(optionsViewModel.options.count))
      idealHeight.priority = UILayoutPriority(999)
      idealHeight.isActive = true
    } else if let textViewModel = textViewModel {
      textView.text = textViewModel.initialValue

      containerStackView.addArrangedSubview(textView)

      let maxHeight = textView.heightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.heightAnchor)
      maxHeight.priority = .required
      maxHeight.isActive = true

      let idealHeight = textView.heightAnchor.constraint(
        equalToConstant: textView.sizeThatFits(safeAreaLayoutGuide.layoutFrame.size).height)
      idealHeight.priority = UILayoutPriority(999)
      idealHeight.isActive = true
    }
  }
}

// MARK: - UITableViewDataSource

extension DesignReviewSuboptimalAlertView: UITableViewDataSource {
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

    if selectedOption?.displayName == optionsViewModel.options[indexPath.row].displayName {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }

    return cell
  }
}

// MARK: - UITableViewDelegate

extension DesignReviewSuboptimalAlertView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let optionsViewModel = optionsViewModel,
      indexPath.row < optionsViewModel.options.count else {
      return
    }

    if let selectedRow = optionsViewModel.options.firstIndex(where: { $0.displayName == selectedOption?.displayName }),
     selectedRow != indexPath.row {
      _ = self.tableView(self.tableView, willDeselectRowAt: IndexPath(row: selectedRow, section: 0))
    }

    selectedOption = optionsViewModel.options[indexPath.row]
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

    delegate?.alertView(self, valueDidChange: selectedOption)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let optionsViewModel = optionsViewModel,
      indexPath.row < optionsViewModel.options.count else {
      return
    }

    if selectedOption?.displayName == optionsViewModel.options[indexPath.row].displayName {
      tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
      self.tableView(self.tableView, didSelectRowAt: indexPath)
    } else {
      tableView.deselectRow(at: indexPath, animated: false)
      _ = self.tableView(self.tableView, willDeselectRowAt: indexPath)
    }
  }

  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { true }

  func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
    guard let optionsViewModel = optionsViewModel,
      indexPath.row < optionsViewModel.options.count else {
      return nil
    }

    tableView.cellForRow(at: indexPath)?.accessoryType = .none
    return indexPath
  }
}

extension DesignReviewSuboptimalAlertView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    delegate?.alertView(self, valueDidChange: textView.text)
  }
}
