//
//  DesignReviewInspectorTableViewCell.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

protocol DesignReviewInspectorTableViewCellDelegate: NSObjectProtocol {
  func inspectorTableViewCellWasModified(_ cell: DesignReviewInspectorTableViewCell)
}

class DesignReviewInspectorTableViewCell: UITableViewCell {
  static let reuseIdentifier = "DesignReviewInspectorTableViewCell"

  weak var delegate: DesignReviewInspectorTableViewCellDelegate?

  private var attributeModifier: ((Any) -> Void)?

  override var accessoryView: UIView? {
    didSet { setNeedsUpdateConstraints() }
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .value1, reuseIdentifier: reuseIdentifier)

    indentationWidth = .medium
    textLabel?.numberOfLines = 0
    detailTextLabel?.numberOfLines = 2

    clipsToBounds = true
    contentView.clipsToBounds = true

    let selectedView = UIView()
    selectedBackgroundView = selectedView

    textLabel?.font = .body
    detailTextLabel?.font = .body
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    let color = accessoryView?.backgroundColor
    super.setHighlighted(highlighted, animated: animated)
    accessoryView?.backgroundColor = color
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    let color = accessoryView?.backgroundColor
    super.setSelected(selected, animated: animated)
    accessoryView?.backgroundColor = color
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    textLabel?.text = nil
    detailTextLabel?.text = nil
    imageView?.image = nil
    accessoryView = nil
    accessoryType = .none
    editingAccessoryView = nil
    editingAccessoryType = .none
  }

  private var section: DesignReviewInspectorAttributeGroup?

  func configure(reviewable: DesignReviewable?,
                 attribute: DesignReviewInspectorAttribute,
                 inSectionTitle section: DesignReviewInspectorAttributeGroup) {
    accessoryView = nil
    accessoryType = .none
    editingAccessoryView = nil
    editingAccessoryType = .none

    self.section = section

    var indent = 0
    var titlePrefix = ""

    if section == .views,
       let viewAttribute = attribute.value as? UIView,
       let currentView = reviewable as? UIView {
      if currentView == viewAttribute.superview {
        indent = 2
        titlePrefix = "👉 "
      } else if currentView == viewAttribute {
        indent = 1
        titlePrefix = "🎯 "
      } else {
        indent = 0
        titlePrefix = "👇 "
      }
    }

    indentationLevel = indent
    textLabel?.text = titlePrefix + attribute.title

    if let value = attribute.value as? NSObjectProtocol {
      let (accessoryView, text) = accessories(for: attribute)

      if value === reviewable {
        accessoryType = .checkmark
      } else {
        self.accessoryView = accessoryView
        editingAccessoryView = accessoryView
      }

      detailTextLabel?.text = attribute.subtitle ?? text
    } else {
      detailTextLabel?.text = "none"
    }
  }

  func refreshTextOnly(attribute: DesignReviewInspectorAttribute) {
    var text: String?

    switch attribute.value {
    case let value as [AnyObject]:
      text = "\(value.count)"
    case let value as NSAttributedString:
      text = value.string
    case let number as NSNumber:
      let formatter = NumberFormatter()
      formatter.minimumIntegerDigits = 1
      formatter.minimumFractionDigits = 1
      formatter.maximumFractionDigits = 2
      text = formatter.string(from: number)

      let boolID = CFBooleanGetTypeID()
      let numID = CFGetTypeID(number)
      let isBoolean = numID == boolID

      if isBoolean { text = number.boolValue ? "true" : "false" }
    case let value as NSValue:
      text = ValueTransformer().transformedValue(value) as? String

    case let color as UIColor:
      text = UIColorValueTransformer().transformedValue(color) as? String
    case let value as UIFont:
      text = "\(value.fontName), \(value.pointSize)"
    case is UIBarButtonItem, is UIImage:
      text = nil
    case let value as UIView:
      text = value.summaryDisplayName
    case let value as UIViewController:
      text = String(describing: value.classForCoder)
    default:
      if let value = attribute.value { text = "\(value)" }
    }

    if let value = attribute.value as? NSObjectProtocol,
      CFGetTypeID(value) == CGColor.typeID {
      text = UIColorValueTransformer().transformedValue(value) as? String
    }

    detailTextLabel?.text = attribute.subtitle ?? text
  }

  private func accessories(for attribute: DesignReviewInspectorAttribute) -> (UIView?, String?) {
    var accessoryView: UIView?
    var text: String?

    switch attribute.value {
    case let value as [AnyObject]:
      text = "\(value.count)"
    case let value as NSAttributedString:
      text = value.string
    case let number as NSNumber:
      let formatter = NumberFormatter()
      formatter.minimumIntegerDigits = 1
      formatter.minimumFractionDigits = 1
      formatter.maximumFractionDigits = 2
      text = formatter.string(from: number)

      let boolID = CFBooleanGetTypeID()
      let numID = CFGetTypeID(number)
      let isBoolean = numID == boolID

      if isBoolean {
        text = number.boolValue ? "true" : "false"

        let sonOfASwitch = UISwitch()

        sonOfASwitch.alpha = attribute.isModifiable ? 1 : 0.5
        sonOfASwitch.isOn = number.boolValue
        sonOfASwitch.isEnabled = attribute.isModifiable
        sonOfASwitch.tintColor = .success3

        sonOfASwitch.addTarget(self, action: #selector(accessoryInteracted), for: .valueChanged)

        attributeModifier = (attribute as? DesignReviewMutableAttribute)?.modifier
        accessoryView = sonOfASwitch
      } else {
        let stepper = UIStepper()

        stepper.minimumValue = -CGFloat.infinity
        stepper.maximumValue = CGFloat.infinity
        stepper.stepValue = (attribute as? DesignReviewMutableAttribute)?.modifierIncrementSize ?? Double(CGFloat.extraExtraSmall)
        stepper.value = number.doubleValue
        stepper.isEnabled = attribute.isModifiable
        stepper.alpha = attribute.isModifiable ? 1 : 0.5

        stepper.addTarget(self, action: #selector(accessoryInteracted), for: .valueChanged)
        attributeModifier = (attribute as? DesignReviewMutableAttribute)?.modifier
        accessoryView = stepper
      }
    case let value as NSValue:
      text = ValueTransformer().transformedValue(value) as? String
    case let color as UIColor:
      text = UIColorValueTransformer().transformedValue(color) as? String
      accessoryView = DesignReviewUIColorAccessoryView(color: color)
    case let value as UIFont:
      text = "\(value.fontName), \(value.pointSize)"
    case is UIBarButtonItem, is UIImage:
      text = nil
    case let value as UIView:
      text = value.summaryDisplayName
    case let value as UIViewController:
      text = String(describing: value.classForCoder)
    default:
      if let value = attribute.value { text = "\(value)" }
    }

    if let value = attribute.value as? NSObjectProtocol,
      CFGetTypeID(value) == CGColor.typeID {
      text = UIColorValueTransformer().transformedValue(value) as? String
      // swiftlint:disable force_cast
      accessoryView = DesignReviewUIColorAccessoryView(color: UIColor(cgColor: value as! CGColor))
    }

    return (accessoryView, text)
  }

  @objc private func accessoryInteracted(_ sender: Any) {
    if let stepper = sender as? UIStepper {
      attributeModifier?(stepper.value)
      delegate?.inspectorTableViewCellWasModified(self)
    } else if let switcher = sender as? UISwitch {
      attributeModifier?(switcher.isOn)
      delegate?.inspectorTableViewCellWasModified(self)
    }
  }
}
