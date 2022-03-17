//
//  DesignReviewInspectorViewModel.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

/// Corresponds to an individual row in the inspector table view.
struct DesignReviewInspectorRow {
  /// The attribute (think: the actual data) of the given row
  let attribute: DesignReviewInspectorAttribute

  /// The title of the given row
  let title: String
}

/// Corresponds to a section in the inspector table view.
struct DesignReviewInspectorSection {
  /// Whether the given section is currently expanded (`true`), or collapsed (`false`)
  var isExpanded = true

  /// The rows displayed in the given section
  var rows: [DesignReviewInspectorRow]

  /// The title of the given section
  let title: DesignReviewInspectorAttributeGroup
}

enum DesignReviewInspectorSegmentedIndex: Int {
  case landing, constraints, twoDimensionalHierarchy, threeDimensionalHierarchy

  var sections: [DesignReviewInspectorAttributeGroup] {
    switch self {
    case .landing:
      return [.summary, .screenshot, .accessibility, .typography, .styling, .general]
    case .constraints:
      return [.summary, .screenshot, .contentHugging, .compressionResistance, .generalLayout, .constraints]
    case .twoDimensionalHierarchy:
      return [.summary, .screenshot, .classHierarchy, .viewHierarchy]
    case .threeDimensionalHierarchy:
      return []
    }
  }
}

class DesignReviewInspectorViewModel {
  weak var coordinator: DesignReviewInspectorCoordinator?
  private(set) weak var reviewable: DesignReviewable?
  private(set) var sections = [DesignReviewInspectorSection]()
  private var allSections = [DesignReviewInspectorSection]()

  private var currentSegmentedIndex: DesignReviewInspectorSegmentedIndex = .landing
  private var actualCreatedSegmentedIndices = [DesignReviewInspectorSegmentedIndex]()

  init(reviewable: DesignReviewable?, userDefinedCustomAttributes: DesignReviewCustomAttributeSet? = nil) {
    self.reviewable = reviewable

    let reviewableAttributes = reviewable?.createReviewableAttributes()

    allSections = DesignReviewInspectorAttributeGroup.allCases.compactMap { attributeGroup in
      guard let attributes = reviewableAttributes?[attributeGroup] else { return nil }
      let rows = attributes.compactMap { DesignReviewInspectorRow(attribute: $0, title: $0.title) }

      var section = DesignReviewInspectorSection(rows: rows, title: attributeGroup)

      switch attributeGroup {
      case .classHierarchy, .constraints, .contentHugging, .compressionResistance:
        section.isExpanded = false
      default:
        break
      }

      return section
    }

    accountForUserDefinedCustomAttributes(userDefinedCustomAttributes)

    // initial visible sections should be 'generic'
    updateVisibleSections(segmentedIndex: .landing)
  }

  func attribute(for indexPath: IndexPath) -> DesignReviewInspectorAttribute? {
    guard indexPath.section < sections.count,
      indexPath.row < sections[indexPath.section].rows.count else {
        return nil
    }

    return sections[indexPath.section].rows[indexPath.row].attribute
  }

  func convertRawControlIndexToActualIndex(_ rawIndex: Int) -> DesignReviewInspectorSegmentedIndex? {
    guard rawIndex < actualCreatedSegmentedIndices.count else { return nil }
    return actualCreatedSegmentedIndices[rawIndex]
  }

  func expandedStateForSection(_ section: Int) -> Bool {
    guard section < sections.count else { return false }
    return sections[section].isExpanded
  }

  func showDesignReviewIfPossible(for indexPath: IndexPath) {
    guard let attribute = attribute(for: indexPath) else { return }

    if let value = attribute.value as? DesignReviewable, value !== reviewable {
      coordinator?.presentDesignReview(for: value)
    }
  }

  func close() {
    coordinator?.finish()
  }

  func closeForGood() {
    allSections.removeAll()
    sections.removeAll()
    coordinator?.finish()
  }

  func showAlertIfPossible(for attribute: DesignReviewInspectorAttribute,
                           in context: UIViewController,
                           changeHandler: ((Any) -> Void)?) {
    guard attribute.isAlertable else { return }

    var newViewModel: DesignReviewSuboptimalAlertViewModelProtocol
    if attribute is DesignReviewMutableAttribute, let initialValue = attribute.value as? String {
      newViewModel = DesignReviewSuboptimalAlertTextViewModel(
        title: attribute.title,
        subtitle: nil,
        initialValue: initialValue,
        onOptionChosen: { newOption in
          changeHandler?(newOption)
        })
    } else {
      var initialOption: DesignReviewAttributeOptionSelectable?
      if let value = attribute.value as? String { // if it happens to be a string, make sure it's part of the alertable set
        initialOption = attribute.alertableOptions.first(where: { $0.displayName == value })
      } else if let value = attribute.value as? DesignReviewAttributeOptionSelectable {
        // failing that, the attribute value should be a conformant enum type in order to get to here...
        initialOption = value
      }

      newViewModel = DesignReviewSuboptimalAlertOptionsViewModel(
        title: attribute.title,
        subtitle: nil,
        options: attribute.alertableOptions,
        initialOption: initialOption,
        onOptionChosen: { newOption in
          changeHandler?(newOption)
        })
    }

    newViewModel.isAlertCancellable = attribute.isAlertCancellable

    coordinator?.showAlert(viewModel: newViewModel, in: context)
  }

  func showColorPicker(initialColor: UIColor, changeHandler: ((UIColor) -> Void)?) {
    coordinator?.showColorPicker(initialColor: initialColor, changeHandler: changeHandler)
  }

  func refreshScreenshot() -> Int? {
    guard let view = reviewable as? UIView,
      let index = allSections.firstIndex(where: { $0.title == .screenshot }),
      let filteredIndex = sections.firstIndex(where: { $0.title == .screenshot }) else {
        return nil
    }
    view.layoutIfNeeded()
    let newScreenshot = view.polaroidSelfie()
    let oldSection = sections[filteredIndex]

    let newSection = DesignReviewInspectorSection(
      isExpanded: oldSection.isExpanded,
      rows: [DesignReviewInspectorRow(
        attribute: DesignReviewScreenshotAttribute(image: newScreenshot),
        title: DesignReviewInspectorAttributeGroup.screenshot.title)],
      title: .screenshot)

    allSections[index] = newSection
    sections[filteredIndex] = newSection

    return index
  }

  func createSegmentedControlItems() -> [Any] {
    var items = [UIImage?]()

    let landingHasData = !DesignReviewInspectorSegmentedIndex.landing.sections.filter({ searchCandidate in
      allSections.contains(where: { $0.title == searchCandidate })
    }).isEmpty

    let constraintsHasData = !DesignReviewInspectorSegmentedIndex.constraints.sections.filter({ searchCandidate in
      // don't let preview/summary influence segmented tab visibility for non-landing tabs
      if searchCandidate == .screenshot || searchCandidate == .summary { return false }

      return allSections.contains(where: { $0.title == searchCandidate })
    }).isEmpty

    let hierarchyHasData = !DesignReviewInspectorSegmentedIndex.twoDimensionalHierarchy.sections.filter({ searchCandidate in
      // don't let preview/summary influence segmented tab visibility for non-landing tabs
      if searchCandidate == .screenshot || searchCandidate == .summary { return false }

      return allSections.contains(where: { $0.title == searchCandidate })
    }).isEmpty

    let addThreeDimensionalItem = (reviewable as? UIView) != nil

    if #available(iOS 13, *) {
      if landingHasData { items.append(UIImage(systemName: "person.crop.rectangle")) }
      if constraintsHasData { items.append(UIImage(systemName: "ruler")) }
      if hierarchyHasData { items.append(UIImage(systemName: "rectangle.on.rectangle")) }
      if addThreeDimensionalItem { items.append(UIImage(systemName: "square.stack.3d.down.right")) }
    } else {
      if landingHasData { items.append(UIImage(named: "person-crop-rectangle")) }
      if constraintsHasData { items.append(UIImage(named: "square-and-line-vertical-and-square")) }
      if hierarchyHasData { items.append(UIImage(named: "rectangle-on-rectangle")) }
      if addThreeDimensionalItem { items.append(UIImage(named: "square-stack-3d-down-right")) }
    }

    if landingHasData { actualCreatedSegmentedIndices.append(.landing) }
    if constraintsHasData { actualCreatedSegmentedIndices.append(.constraints) }
    if hierarchyHasData { actualCreatedSegmentedIndices.append(.twoDimensionalHierarchy) }
    if addThreeDimensionalItem { actualCreatedSegmentedIndices.append(.threeDimensionalHierarchy) }

    return items.compactMap { $0 }
  }

  func updateVisibleSections(segmentedIndex: DesignReviewInspectorSegmentedIndex) {
    currentSegmentedIndex = segmentedIndex
    sections = allSections.filter { segmentedIndex.sections.contains($0.title) }
  }

  func titleForSection(_ section: Int) -> String {
    guard section < sections.count else { return "" }
    return sections[section].title.title
  }

  @discardableResult
  func toggleExpandedForSection(_ section: Int) -> Bool {
    guard section < sections.count else { return false }
    sections[section].isExpanded.toggle()

    return sections[section].isExpanded
  }

  private func accountForUserDefinedCustomAttributes(_ attributes: DesignReviewCustomAttributeSet?) {
    guard let reviewable = reviewable else { return }

    attributes?.iterate(performing: { attribute in
      let convertedAttribute = attribute.toMutableAttribute(for: reviewable)
      let newRow = DesignReviewInspectorRow(attribute: convertedAttribute, title: convertedAttribute.title)

      guard let internalIndex = self.allSections.firstIndex(where: { $0.title == attribute.group }) else {
        self.allSections.append(DesignReviewInspectorSection(rows: [newRow], title: attribute.group))
        return
      }

      self.allSections[internalIndex].rows.append(newRow)
    })
  }
}
