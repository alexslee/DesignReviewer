//
//  String+Formatting.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation

extension String {
  func string(prepending: String? = nil, appending: String? = nil, separator: String = "") -> String {
    [prepending, self, appending].compactMap { $0 }.joined(separator: separator)
  }

  var trimmed: String? {
    let trimmedString = trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedString.isEmpty ? nil : trimmedString
  }
}
