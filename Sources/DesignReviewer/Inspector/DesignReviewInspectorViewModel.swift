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
}

class DesignReviewInspectorViewModel {
  weak var coordinator: DesignReviewCoordinator?
  private(set) weak var reviewable: DesignReviewable?
  private(set) var sections = [DesignReviewInspectorSection]()
  private var allSections = [DesignReviewInspectorSection]()

  private var currentSegmentedIndex: DesignReviewInspectorSegmentedIndex = .landing

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

  func expandedStateForSection(_ section: Int) -> Bool {
    guard section < sections.count else { return false }
    return sections[section].isExpanded
  }

  func presentExplodedHierarchy() {
    guard let reviewable = reviewable else { return }
    coordinator?.presentExplodedHierarchy(reviewable: reviewable)
  }

  func refreshScreenshot() -> Int? {
    guard let view = reviewable as? UIView,
      let index = allSections.firstIndex(where: { $0.title == .preview }) else {
        return nil
    }
    view.layoutSubviews()
    let newScreenshot = view.polaroidSelfie()
    let oldSection = allSections[index]

    allSections[index] = DesignReviewInspectorSection(
      isExpanded: oldSection.isExpanded,
      rows: [DesignReviewInspectorRow(
        attribute: DesignReviewPreviewAttribute(image: newScreenshot),
        title: DesignReviewInspectorAttributeGroup.preview.title)],
      title: .preview)

    updateVisibleSections(segmentedIndex: currentSegmentedIndex)

    return index
  }

  func segmentedControlItems() -> [Any] {
    var items = [UIImage?]()

    if #available(iOS 13, *) {
      items.append(UIImage(systemName: "person.crop.rectangle"))
      items.append(UIImage(systemName: "ruler"))
      items.append(UIImage(systemName: "rectangle.on.rectangle"))
      items.append(UIImage(systemName: "square.stack.3d.down.right"))
    } else {
      items.append(UIImage(named: "person-crop-rectangle"))
      items.append(UIImage(named: "square-and-line-vertical-and-square"))
      items.append(UIImage(named: "rectangle-on-rectangle"))
      items.append(UIImage(named: "square-stack-3d-down-right"))
    }
    return items.compactMap { $0 }
  }

  func updateVisibleSections(segmentedIndex: DesignReviewInspectorSegmentedIndex) {
    currentSegmentedIndex = segmentedIndex

    if segmentedIndex == .landing {
      sections = allSections.filter {
        switch $0.title {
        case .summary, .preview, .accessibility, .typography, .appearance, .general:
          return true
        default:
          return false
        }
      }
    } else if segmentedIndex == .constraints {
      sections = allSections.filter {
        switch $0.title {
        case .summary, .preview, .horizontal, .vertical, .hugging, .resistance, .layout, .constraints:
          return true
        default:
          return false
        }
      }
    } else if segmentedIndex == .twoDimensionalHierarchy {
      sections = allSections.filter {
        switch $0.title {
        case .summary, .preview, .classes, .views, .controllers:
          return true
        default:
          return false
        }
      }
    }
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
