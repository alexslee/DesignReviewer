//
//  DesignReviewInspectorViewController.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

class DesignReviewInspectorViewController: UIViewController {
  private let viewModel: DesignReviewInspectorViewModel

  private lazy var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

  private(set) lazy var tableView: UITableView = {
    let view = UITableView(frame: .zero, style: .plain)
    view.backgroundColor = .background
    view.dataSource = self
    view.delegate = self

    view.estimatedRowHeight = .extraExtraLarge
    view.estimatedSectionFooterHeight = 0
    view.estimatedSectionHeaderHeight = .extraExtraLarge

    view.keyboardDismissMode = .interactive

    view.rowHeight = UITableView.automaticDimension
    view.sectionFooterHeight = UITableView.automaticDimension
    view.sectionHeaderHeight = UITableView.automaticDimension

    view.translatesAutoresizingMaskIntoConstraints = false

    view.register(DesignReviewInspectorSummaryTableViewCell.self,
                  forCellReuseIdentifier: DesignReviewInspectorSummaryTableViewCell.reuseIdentifier)
    view.register(DesignReviewInspectorTableViewCell.self,
                  forCellReuseIdentifier: DesignReviewInspectorTableViewCell.reuseIdentifier)
    view.register(DesignReviewInspectorPreviewTableViewCell.self,
                  forCellReuseIdentifier: DesignReviewInspectorPreviewTableViewCell.reuseIdentifier)
    view.register(DesignReviewCollapsibleHeaderView.self,
                  forHeaderFooterViewReuseIdentifier: DesignReviewCollapsibleHeaderView.reuseIdentifier)

    return view
  }()

  private lazy var explodedHierarchyViewController: DesignReviewExplodedHierarchyViewController? = {
    guard let reviewable = viewModel.reviewable else { return nil }

    guard let root = viewModel.coordinator?.appWindow else { return nil }

    let explodedViewModel = DesignReviewExplodedHierarchyViewModel(
      coordinator: viewModel.coordinator,
      rootReviewable: reviewable)

    let viewController = DesignReviewExplodedHierarchyViewController(root: root, viewModel: explodedViewModel)
    viewController.view.isHidden = true

    return viewController
  }()

  private var explodedHierarchyView: UIView? {
    explodedHierarchyViewController?.view
  }

  private lazy var segmentedControl: UISegmentedControl = {
    let control = UISegmentedControl(items: viewModel.segmentedControlItems())
    control.selectedSegmentIndex = 0
    control.addTarget(self, action: #selector(segmentedIndexDidChange), for: .valueChanged)
    return control
  }()

  // MARK: - Lifecycle

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(viewModel: DesignReviewInspectorViewModel) {
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(tableView)
    NSLayoutConstraint.activate(tableView.constraints(toView: view))

    navigationItem.titleView = segmentedControl
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = nil
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if let reviewable = viewModel.reviewable {
      title = String(describing: reviewable.classForCoder)
    }
  }

  // MARK: - Helpers

  private func layoutExplodedHierarchyIfNecessary() {
    guard let explodedHierarchyView = explodedHierarchyView, !explodedHierarchyView.isHidden else { return }

    if explodedHierarchyView.superview == view { return }

    explodedHierarchyView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(explodedHierarchyView)
    NSLayoutConstraint.activate(explodedHierarchyView.constraints(toView: view))

    if let container = explodedHierarchyView.subviews.first(where: {
      $0 is DesignReviewExplodedHierarchyContainerView
    }) as? DesignReviewExplodedHierarchyContainerView {
      container.jumpStart()
    }
  }

  @objc private func segmentedIndexDidChange() {
    guard let segmentedIndex = DesignReviewInspectorSegmentedIndex(
      rawValue: segmentedControl.selectedSegmentIndex) else {
      return
    }

    if segmentedIndex == .threeDimensionalHierarchy {
      tableView.isHidden = true
      explodedHierarchyView?.isHidden = false

      layoutExplodedHierarchyIfNecessary()
      return
    } else {
      tableView.isHidden = false
      explodedHierarchyView?.isHidden = true
    }

    viewModel.updateVisibleSections(segmentedIndex: segmentedIndex)
    tableView.reloadData()
  }
}

// MARK: - DesignReviewCollapsibleHeaderViewDelegate

extension DesignReviewInspectorViewController: DesignReviewCollapsibleHeaderViewDelegate {
  func sectionHeaderShouldToggleExpandedState(_ view: DesignReviewCollapsibleHeaderView) {
    let sectionIndex = view.tag
    guard !(viewModel.attribute(for: IndexPath(row: 0, section: sectionIndex)) is DesignReviewPreviewAttribute) else { return }

    feedbackGenerator.prepare()
    feedbackGenerator.impactOccurred()

    let newExpanded = viewModel.toggleExpandedForSection(sectionIndex)

    view.expand(newExpanded) { [weak self] in
      guard let self = self else { return }

      // reloading all the rows, rather than the whole section directly, prevents extra header animations
      let rowCount = self.tableView.numberOfRows(inSection: sectionIndex)
      let indicesToReload = (0..<rowCount).map { IndexPath(row: $0, section: sectionIndex) }

      self.tableView.reloadRows(at: indicesToReload, with: .fade)
    }
  }
}

// MARK: - DesignReviewInspectorTableViewCellDelegate

extension DesignReviewInspectorViewController: DesignReviewInspectorTableViewCellDelegate {
  func inspectorTableViewCellWasModified(_ cell: DesignReviewInspectorTableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell),
      let attribute = viewModel.attribute(for: indexPath) else {
        return
    }

    cell.refreshTextOnly(attribute: attribute)
    if let screenshotSectionIndex = viewModel.refreshScreenshot() {
      tableView.reloadSections(IndexSet([screenshotSectionIndex]), with: .none)
    }
  }
}

// MARK: - UITableViewDataSource

extension DesignReviewInspectorViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let attribute = viewModel.attribute(for: indexPath) else {
      return tableView.emptyCell(for: indexPath)
    }

    if let summaryAttribute = attribute as? DesignReviewSummaryAttribute,
       let cell = tableView.dequeueReusableCell(
        withIdentifier: DesignReviewInspectorSummaryTableViewCell.reuseIdentifier,
        for: indexPath) as? DesignReviewInspectorSummaryTableViewCell {
      cell.configure(title: summaryAttribute.title,
                     subtitle: summaryAttribute.subtitle,
                     image: summaryAttribute.image)
      return cell
    }

    if let previewAttribute = attribute as? DesignReviewPreviewAttribute,
       let cell = tableView.dequeueReusableCell(
        withIdentifier: DesignReviewInspectorPreviewTableViewCell.reuseIdentifier,
        for: indexPath) as? DesignReviewInspectorPreviewTableViewCell {
      cell.configure(image: previewAttribute.image)
      return cell
    }

    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: DesignReviewInspectorTableViewCell.reuseIdentifier,
      for: indexPath) as? DesignReviewInspectorTableViewCell else {
        return tableView.emptyCell(for: indexPath)
    }

    cell.configure(reviewable: viewModel.reviewable,
                   attribute: attribute,
                   inSectionTitle: viewModel.sections[indexPath.section].title)
    cell.delegate = self
    cell.tag = indexPath.row

    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard section < viewModel.sections.count else { return 0 }
    return viewModel.sections[section].rows.count
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.sections.count
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let attribute = viewModel.attribute(for: IndexPath(row: 0, section: section)),
       attribute is DesignReviewSummaryAttribute {
      return nil
    }

    let reuseIdentifier = DesignReviewCollapsibleHeaderView.reuseIdentifier
    guard let header = tableView.dequeueReusableHeaderFooterView(
      withIdentifier: reuseIdentifier) as? DesignReviewCollapsibleHeaderView else {
        return nil
    }

    var isExpandable = true
    if let attribute = viewModel.attribute(for: IndexPath(row: 0, section: section)),
       attribute is DesignReviewPreviewAttribute {
      isExpandable = false
    }

    header.configure(section: section,
                     title: viewModel.titleForSection(section),
                     delegate: self,
                     isExpandable: isExpandable)
    header.expand(viewModel.expandedStateForSection(section))

    return header
  }
}

// MARK: - UITableViewDelegate

extension DesignReviewInspectorViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let attribute = viewModel.attribute(for: indexPath) else { return }

    if let value = attribute.value as? DesignReviewable, value !== viewModel.reviewable {
      let viewModel = DesignReviewInspectorViewModel(reviewable: value)
      viewModel.coordinator = self.viewModel.coordinator
      let controller = DesignReviewInspectorViewController(viewModel: viewModel)

      navigationController?.pushViewController(controller, animated: true)
    }

    tableView.deselectRow(at: indexPath, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if let attribute = viewModel.attribute(for: IndexPath(row: 0, section: section)),
       attribute is DesignReviewSummaryAttribute {
      return 0
    }

    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if viewModel.attribute(for: indexPath) is DesignReviewPreviewAttribute {
      return UITableView.automaticDimension
    }

    return viewModel.expandedStateForSection(indexPath.section) ? UITableView.automaticDimension : 0
  }

  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return !(viewModel.attribute(for: indexPath) is DesignReviewPreviewAttribute)
  }
}
