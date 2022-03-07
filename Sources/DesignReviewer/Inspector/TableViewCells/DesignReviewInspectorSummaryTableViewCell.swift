//
//  DesignReviewInspectorSummaryTableViewCell.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

class DesignReviewInspectorSummaryTableViewCell: UITableViewCell {
  static let reuseIdentifier = "DesignReviewInspectorSummaryTableViewCell"

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

    backgroundView = UIView()
    backgroundColor = nil
    clipsToBounds = true
    contentView.clipsToBounds = true
    detailTextLabel?.numberOfLines = 0
    directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: .large, bottom: 0, trailing: .large)
    imageView?.clipsToBounds = true
    imageView?.contentMode = .scaleAspectFit
    imageView?.tintColor = .monochrome5
    indentationWidth = .medium
    separatorInset = UIEdgeInsets(top: 0, left: .large, bottom: 0, right: .large)
    textLabel?.font = .title
    textLabel?.numberOfLines = 0
  }

  func configure(title: String, subtitle: String?, image: UIImage?) {
    textLabel?.text = title
    detailTextLabel?.text = subtitle
    imageView?.image = image
  }
}
