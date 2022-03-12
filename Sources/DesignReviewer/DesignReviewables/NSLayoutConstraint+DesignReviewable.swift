//
//  NSLayoutConstraint+DesignReviewable.swift
//
//
//  Created by Alex Lee on 3/4/22.
//

import Foundation
import UIKit

extension NSLayoutConstraint: DesignReviewable {
  public func createReviewableAttributes() -> [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]] {
    var attributes = [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]]()

    // build list of constraint attributes+relations
    attributes[.general] = [DesignReviewInspectorAttribute]()

    attributes[.general]?.append(DesignReviewMutableAttribute(
      title: "Is Active",
      keyPath: "active",
      reviewable: self))
    attributes[.general]?.append(DesignReviewEnumAttribute<NSLayoutConstraint.Attribute>(
      title: "First Attribute",
      keyPath: "firstAttribute",
      reviewable: self))
    attributes[.general]?.append(DesignReviewMutableAttribute(
      title: "First Item",
      keyPath: "firstItem",
      reviewable: self))

    attributes[.general]?.append(DesignReviewEnumAttribute<NSLayoutConstraint.Attribute>(
      title: "Second Attribute",
      keyPath: "secondAttribute",
      reviewable: self))
    attributes[.general]?.append(DesignReviewMutableAttribute(
      title: "Second Item",
      keyPath: "secondItem",
      reviewable: self))

    attributes[.general]?.append(DesignReviewEnumAttribute<NSLayoutConstraint.Relation>(
      title: "Relation",
      keyPath: "relation",
      reviewable: self))

    attributes[.general]?.append(DesignReviewMutableAttribute(
      title: "Constant",
      keyPath: "constant",
      reviewable: self,
      modifier: { [weak self] newVal in
        guard let self = self,
          let rawConstant = newVal as? Double else {
            return
        }

        self.constant = CGFloat(rawConstant)
      }
    ))

    attributes[.general]?.append(DesignReviewMutableAttribute(
      title: "Multiplier",
      keyPath: "multiplier",
      reviewable: self))

    attributes[.general]?.append(DesignReviewMutableAttribute(
      title: "Priority",
      keyPath: "priority",
      reviewable: self))

    return attributes
  }
}
