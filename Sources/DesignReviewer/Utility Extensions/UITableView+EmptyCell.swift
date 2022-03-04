//
//  UITableView+EmptyCell.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension UITableView {
  /**
   Returns the empty cell that is used for failure cases. As a fail-safe, it
   registers the empty cell for each call.
   */
  func emptyCell(for indexPath: IndexPath) -> UITableViewCell {
    let reuseIdentifier = UITableViewCell.emptyIdentifier

    // There is no documentation on how expensive of an operation this is
    // (to register the empty cell every time this method is called) but the
    // hypothesis is that it isn't and also since this method is used as a
    // fail-safe it technically would never be called in production.
    register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

    return dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
  }
}

extension UITableViewCell {
  /// Identifier used for failed guard/else cases as a fallback.
  static let emptyIdentifier = "empty"
}
