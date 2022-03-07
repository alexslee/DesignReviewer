//
//  DesignReviewUIImageAccessoryView.swift
//  
//
//  Created by Alex Lee on 3/6/22.
//

import UIKit

class DesignReviewUIImageAccessoryView: UIView {
  private static let size = CGSize(width: 144, height: .extraExtraLarge)

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.setContentHuggingPriority(.required, for: .horizontal)
    imageView.setContentHuggingPriority(.required, for: .vertical)

    imageView.backgroundColor = .monochrome5.withAlphaComponent(0.25)

    return imageView
  }()

  private lazy var stackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .fill
    stack.translatesAutoresizingMaskIntoConstraints = false

    return stack
  }()

  private lazy var textLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = .finePrint
    label.numberOfLines = 1
    label.textColor = .monochrome5

    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    return label
  }()

  override var intrinsicContentSize: CGSize { Self.size }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(image: UIImage?, imageInfo: String?) {
    super.init(frame: CGRect(x: 0, y: 0, width: Self.size.width, height: Self.size.height))

    imageView.image = image
    textLabel.text = imageInfo

    stackView.backgroundColor = .monochrome5.withAlphaComponent(0.5)
    stackView.layer.cornerRadius = .extraSmall
    stackView.clipsToBounds = true

    addSubview(stackView)
    stackView.addArrangedSubview(textLabel)
    stackView.addArrangedSubview(imageView)

    NSLayoutConstraint.activate(stackView.constraints(toView: self, withEqualInset: .extraExtraSmall))
  }
}
