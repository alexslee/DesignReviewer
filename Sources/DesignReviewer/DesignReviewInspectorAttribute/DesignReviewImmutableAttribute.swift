//
//  DesignReviewImmutableAttribute.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation

/// As the name suggests, this isn't fetched dynamically when needed to be displayed, but rather
/// statically assigned a value on init.
class DesignReviewImmutableAttribute: DesignReviewInspectorAttribute, Equatable {
  let keyPath: String
  let subtitle: String?
  let title: String
  let value: Any?

  init(title: String,
       subtitle: String? = nil,
       keyPath: String,
       value: Any?) {
    self.title = title
    self.subtitle = subtitle
    self.keyPath = keyPath
    self.value = value
  }

  static func == (lhs: DesignReviewImmutableAttribute, rhs: DesignReviewImmutableAttribute) -> Bool {
    return lhs.title == rhs.title
  }
}
