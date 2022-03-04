//
//  DesignReviewCollapsibleHeaderView.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

protocol DesignReviewCollapsibleHeaderViewDelegate: AnyObject {
    func sectionHeaderShouldToggleExpandedState(_ view: DesignReviewCollapsibleHeaderView)
}

class DesignReviewCollapsibleHeaderView: UITableViewHeaderFooterView {
  static let reuseIdentifier = "DesignReviewCollapsibleHeaderView"

  weak var delegate: DesignReviewCollapsibleHeaderViewDelegate? {
    didSet {
      tapper.isEnabled = delegate != nil
      imageView.isHidden = delegate == nil
    }
  }

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()

    if #available(iOS 13, *) {
      imageView.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
    } else {
      imageView.image = UIImage(named: "chevron-down")?.withRenderingMode(.alwaysTemplate)
    }

    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .monochrome4
    imageView.translatesAutoresizingMaskIntoConstraints = false

    return imageView
  }()

  private lazy var label: UILabel = {
    let label = UILabel()
    label.font = .bodyStrong
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.textColor = .monochrome5

    label.translatesAutoresizingMaskIntoConstraints = false

    return label
  }()

  private lazy var tapper = UITapGestureRecognizer(target: self, action: #selector(tapTapRevenge))

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)

    contentView.addSubview(imageView)
    contentView.addSubview(label)

    NSLayoutConstraint.activate([
      imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      imageView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      imageView.widthAnchor.constraint(equalToConstant: .large),
      imageView.heightAnchor.constraint(equalToConstant: .large)
    ])

    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .extraSmall),
      label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.extraSmall),
      label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -.medium)
    ])

    tapper.isEnabled = false
    addGestureRecognizer(tapper)
  }

  @objc private func tapTapRevenge() {
    delegate?.sectionHeaderShouldToggleExpandedState(self)
  }

  func configure(section: Int,
                 title: String,
                 delegate: DesignReviewCollapsibleHeaderViewDelegate,
                 isExpandable: Bool = true) {
    tag = section
    self.delegate = delegate
    label.text = title

    imageView.isHidden = !isExpandable
    label.sizeToFit()
  }

  func expand(_ isExpanded: Bool, completion: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.25, animations: { [weak self] in
      let angle = -CGFloat(Double.pi) / 2
      self?.imageView.transform = isExpanded ? .identity : CGAffineTransform(rotationAngle: angle)
    }, completion: { _ in
      completion?()
    })
  }
}
