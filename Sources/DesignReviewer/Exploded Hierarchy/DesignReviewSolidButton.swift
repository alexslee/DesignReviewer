//
//  DesignReviewSolidButton.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

class DesignReviewSolidButton: UIButton {
  var isTemplate = true

  var buttonText: String? {
    didSet {
      setTitle(buttonText, for: .normal)
    }
  }

  var buttonImage: UIImage? {
    didSet {
      setImage(buttonImage?.withRenderingMode(isTemplate ? .alwaysTemplate : .alwaysOriginal), for: .normal)
      updateInsets(buttonText: buttonText, buttonImage: buttonImage)
    }
  }

  private var enabledColor = UIColor.primary3
  private let disabledColor = UIColor.primary2
  private var highlightedColor = UIColor.primary4

  override var isEnabled: Bool {
    didSet {
      backgroundColor = isEnabled ? enabledColor : disabledColor
    }
  }

  override var isHighlighted: Bool {
    didSet {
      guard isEnabled else { return }
      backgroundColor = isHighlighted ? highlightedColor : enabledColor
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience init(buttonText: String?) {
    self.init(buttonText: buttonText, image: nil)
  }

  init(buttonText: String?, image: UIImage?) {
    self.buttonText = buttonText
    super.init(frame: .zero)
    setTitle(buttonText, for: .normal)
    setTitleColor(.monochrome0, for: .normal)
    setTitleColor(.monochrome0, for: .disabled)
    setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
    tintColor = .monochrome0
    titleLabel?.font = .bodyStrong
    layer.cornerRadius = .extraExtraSmall
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = enabledColor
    updateInsets(buttonText: buttonText, buttonImage: image)
  }

  private func updateInsets(buttonText: String?, buttonImage: UIImage?) {
    if buttonText != nil && buttonImage != nil {
        titleEdgeInsets = UIEdgeInsets(top: 0,
                                       left: .small,
                                       bottom: 0,
                                       right: -.small)
        contentEdgeInsets = UIEdgeInsets(top: 0,
                                         left: 0,
                                         bottom: 0,
                                         right: .small) // To counter the title's left insets above
    }

    contentEdgeInsets = UIEdgeInsets(top: 0,
                                     left: .small,
                                     bottom: 0,
                                     right: contentEdgeInsets.right + .small)
  }

  func setCustomHighlightedColor(_ color: UIColor) {
    highlightedColor = color
  }

  func setCustomEnabledColor(_ color: UIColor) {
    enabledColor = color
  }
}

