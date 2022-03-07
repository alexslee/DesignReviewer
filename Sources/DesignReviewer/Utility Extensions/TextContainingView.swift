//
//  TextContainingView.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

/// Convenience wrapper to quickly identify system views that contain text
protocol TextContainingView: UIView {}

extension UILabel: TextContainingView {}

extension UITextView: TextContainingView {}

extension UITextField: TextContainingView {}
