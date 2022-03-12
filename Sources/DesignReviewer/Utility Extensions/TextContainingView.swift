//
//  TextContainingView.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

/// Convenience wrapper to quickly identify system views that contain text
protocol TextContainingView: UIView {
  var sneakPeek: String { get }
  var sneakPeekBuilder: String { get }
}

extension TextContainingView {
  static var sneakPeekLength: Int { 10 }

  var sneakPeek: String {
    "'" + sneakPeekBuilder + "'"
  }
}

extension UILabel: TextContainingView {
  var sneakPeekBuilder: String { (text ?? "").truncatedSelfWithTail }
}

extension UITextView: TextContainingView {
  var sneakPeekBuilder: String { (text ?? "").truncatedSelfWithTail }
}

extension UITextField: TextContainingView {
  var sneakPeekBuilder: String { (text ?? "").truncatedSelfWithTail }
}

extension UIButton: TextContainingView {
  var sneakPeekBuilder: String { (title(for: .normal) ?? "").truncatedSelfWithTail }
}

private extension String {
  var truncatedSelfWithTail: String {
    guard count > UILabel.sneakPeekLength else { return self }

    return String(prefix(UILabel.sneakPeekLength)) + "..."
  }
}
