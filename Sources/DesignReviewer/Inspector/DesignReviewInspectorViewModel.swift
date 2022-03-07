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
  let rows: [DesignReviewInspectorRow]

  /// The title of the given section
  let title: DesignReviewInspectorAttributeGroup
}

enum DesignReviewInspectorSegmentedIndex: Int {
  case landing, constraints, twoDimensionalHierarchy, threeDimensionalHierarchy

  var sections: [DesignReviewInspectorAttributeGroup] {
    switch self {
    case .landing:
      return [.summary, .preview, .accessibility, .typography, .appearance, .behaviour, .general]
    case .constraints:
      return [.summary, .preview, .horizontal, .vertical, .hugging, .resistance, .layout, .constraints]
    case .twoDimensionalHierarchy:
      return [.summary, .preview, .classes, .views, .controllers]
    case .threeDimensionalHierarchy:
      return []
    }
  }
}

class DesignReviewInspectorViewModel {
  weak var coordinator: DesignReviewCoordinator?
  private(set) weak var reviewable: DesignReviewable?
  private(set) var sections = [DesignReviewInspectorSection]()
  private var allSections = [DesignReviewInspectorSection]()

  private var currentSegmentedIndex: DesignReviewInspectorSegmentedIndex = .landing
  private var actualCreatedSegmentedIndices = [DesignReviewInspectorSegmentedIndex]()

  init(reviewable: DesignReviewable?) {
    self.reviewable = reviewable

    let reviewableAttributes = reviewable?.createReviewableAttributes()

    allSections = DesignReviewInspectorAttributeGroup.allCases.compactMap { attributeGroup in
      guard let attributes = reviewableAttributes?[attributeGroup] else { return nil }
      let rows = attributes.compactMap { DesignReviewInspectorRow(attribute: $0, title: $0.title) }

      var section = DesignReviewInspectorSection(rows: rows, title: attributeGroup)

      switch attributeGroup {
      case .classes, .constraints, .hugging, .resistance:
        section.isExpanded = false
      default:
        break
      }

      return section
    }

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

  func showColorPicker(initialColor: UIColor, changeHandler: ((UIColor) -> Void)?) {
    coordinator?.showColorPicker(initialColor: initialColor, changeHandler: changeHandler)
  }

  func refreshScreenshot() -> Int? {
    guard let view = reviewable as? UIView,
      let index = allSections.firstIndex(where: { $0.title == .preview }),
      let filteredIndex = sections.firstIndex(where: { $0.title == .preview }) else {
        return nil
    }
    view.layoutSubviews()
    let newScreenshot = view.polaroidSelfie()
    let oldSection = allSections[index]

    let newSection = DesignReviewInspectorSection(
      isExpanded: oldSection.isExpanded,
      rows: [DesignReviewInspectorRow(
        attribute: DesignReviewPreviewAttribute(image: newScreenshot),
        title: DesignReviewInspectorAttributeGroup.preview.title)],
      title: .preview)

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
      if searchCandidate == .preview || searchCandidate == .summary { return false }

      return allSections.contains(where: { $0.title == searchCandidate })
    }).isEmpty

    let hierarchyHasData = !DesignReviewInspectorSegmentedIndex.twoDimensionalHierarchy.sections.filter({ searchCandidate in
      // don't let preview/summary influence segmented tab visibility for non-landing tabs
      if searchCandidate == .preview || searchCandidate == .summary { return false }

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

  func toggleHUDVisibility(_ isVisible: Bool) {
    coordinator?.toggleHUDVisibility(isVisible)
  }
}
