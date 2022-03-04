//
//  TextContainingView.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

protocol TextContainingView: UIView {
  var content: String? { get }
}

extension UILabel: TextContainingView {
  var content: String? { text?.trimmed }
}

extension UITextView: TextContainingView {
  var content: String? { text?.trimmed }
}

extension UITextField: TextContainingView {
  var content: String? { text?.trimmed }
}
