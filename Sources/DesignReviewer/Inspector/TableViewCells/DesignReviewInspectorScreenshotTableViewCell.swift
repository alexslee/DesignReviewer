//
//  DesignReviewInspectorScreenshotTableViewCell.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

class DesignReviewInspectorScreenshotTableViewCell: UITableViewCell {
  static let reuseIdentifier = "DesignReviewInspectorScreenshotTableViewCell"

  private lazy var previewImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    view.clipsToBounds = true

    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    view.setContentHuggingPriority(.required, for: .vertical)
    view.setContentCompressionResistancePriority(.required, for: .vertical)
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .value1, reuseIdentifier: reuseIdentifier)

    contentView.backgroundColor = .background
    contentView.addSubview(previewImageView)

    NSLayoutConstraint.activate(previewImageView.constraints(
      toView: contentView,
      edges: .all,
      withInsets: UIEdgeInsets(top: .medium, left: 0, bottom: .medium, right: 0)))

    clipsToBounds = true
    contentView.clipsToBounds = true
  }

  func configure(image: UIImage?) {
    previewImageView.image = image
  }
}
