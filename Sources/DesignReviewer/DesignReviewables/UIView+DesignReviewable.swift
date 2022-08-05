//
//  UIView+DesignReviewable.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

extension UIView: DesignReviewable {
  public var subReviewables: [DesignReviewable] { subviews as [DesignReviewable] }

  public func convertBounds(to target: UIView) -> CGRect {
    return convert(bounds, to: target)
  }

  public var isOnScreen: Bool {
    if isHidden || alpha == 0 || frame.equalTo(.zero) || frame.equalTo(window?.bounds ?? UIScreen.main.bounds) {
      return false
    }

    if String(describing: classForCoder).hasPrefix("_") { return false }

    var superviewRef = superview

    let ignoredClassNames = [
      "UINavigationButton",
      "_UIPageViewControllerContentView",
      "UITableViewCellContentView"]

    if ignoredClassNames.contains(where: { $0 == String(describing: classForCoder) }) { return false }

    while superviewRef != nil {
      // early return if you discover the view is of an ignored type
      for ignoredClassName in ignoredClassNames {
        if let ignoredClass = NSClassFromString(ignoredClassName) {
          if superviewRef?.isMember(of: ignoredClass) ?? false { return false }
        }
      }

      // otherwise, continue going up the view hierarchy
      superviewRef = superviewRef?.superview
    }

    return true
  }

  /// Takes a screenshot of the current view as it appears on screen
  public func polaroidSelfie() -> UIImage {
    let screenshot = DesignReviewImageCapturer(size: bounds.size).image(actions: { [weak self] context in
      let contextBounds = context.config.bounds
      self?.drawHierarchy(in: contextBounds, afterScreenUpdates: true)
    })

    return screenshot
  }

  /// Convenience wrapper around some SFSymbols for use in constructing the summary attribute
  private var summarySymbolImage: UIImage? {
    if self is UIImageView {
      return UIImage(systemName: "photo")
    } else if self is UIStackView {
      return UIImage(systemName: "rectangle.stack")
    } else if self is TextContainingView {
      return UIImage(systemName: "text.quote")
    } else {
      return UIImage(systemName: "rectangle")
    }
  }

  private var actualRelatedConstraints: Set<NSLayoutConstraint> {
    var constraintList = [NSLayoutConstraint]()
    var parent = self.superview
    while let superview = parent {
      for constraint in superview.constraints {
        if let first = constraint.firstItem as? UIView, first == self {
          constraintList.append(constraint)
        } else if let second = constraint.secondItem as? UIView, second == self {
          constraintList.append(constraint)
        }
      }

      parent = superview.superview
    }

    return Set(constraintList)
  }

  public func createReviewableAttributes()
  -> [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]] {
    var attributes = [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]]()

    // attempting to create a summary entry
    attributes[.summary] = [DesignReviewInspectorAttribute]()
    attributes[.summary]?.append(DesignReviewSummaryAttribute(
      title: summaryDisplayName,
      subtitle: summaryDescription,
      image: summarySymbolImage))

    // start with screenshot
    if !isHidden, alpha > 0, !bounds.size.equalTo(.zero) {
      let screenshot = polaroidSelfie()
      if !screenshot.size.equalTo(.zero) {
        attributes[.screenshot] = [DesignReviewInspectorAttribute]()
        attributes[.screenshot]?.append(DesignReviewScreenshotAttribute(image: screenshot))
      }
    }

    // build list of classes

    attributes[.classHierarchy] = [DesignReviewInspectorAttribute]()
    var currentClass: AnyClass = classForCoder
    var classHierarchy = [String(describing: currentClass)]

    while let nextClass = currentClass.superclass() {
      classHierarchy.append(String(describing: nextClass))
      currentClass = nextClass
    }

    for `class` in classHierarchy {
      attributes[.classHierarchy]?.append(DesignReviewImmutableAttribute(
        title: String(describing: `class`),
        keyPath: "classForCoder",
        value: ""))
    }

    attributes[.viewHierarchy] = [DesignReviewInspectorAttribute]()
    if let superview = superview {
      attributes[.viewHierarchy]?.append(DesignReviewImmutableAttribute(
        title: String(describing: superview.classForCoder),
        keyPath: "superview",
        value: superview))
    }

    attributes[.viewHierarchy]?.append(DesignReviewImmutableAttribute(
      title: String(describing: classForCoder),
      keyPath: "self",
      value: self))

    for view in subviews.reversed() {
      attributes[.viewHierarchy]?.append(DesignReviewImmutableAttribute(
        title: String(describing: view.classForCoder),
        keyPath: "self",
        value: view))
    }

    // build list for accessibility
    attributes[.accessibility] = [DesignReviewInspectorAttribute]()
    attributes[.accessibility]?.append(DesignReviewMutableAttribute(
      title: "Is Element",
      keyPath: "isAccessibilityElement",
      reviewable: self))
    attributes[.accessibility]?.append(DesignReviewMutableAttribute(
      title: "Identifier",
      keyPath: "accessibilityIdentifier",
      reviewable: self))
    attributes[.accessibility]?.append(DesignReviewMutableAttribute(
      title: "Label",
      keyPath: "accessibilityLabel",
      reviewable: self))
    attributes[.accessibility]?.append(DesignReviewMutableAttribute(
      title: "Value",
      keyPath: "accessibilityValue",
      reviewable: self))
    attributes[.accessibility]?.append(DesignReviewMutableAttribute(
      title: "Hint",
      keyPath: "accessibilityHint",
      reviewable: self))
    attributes[.accessibility]?.append(DesignReviewMutableAttribute(
      title: "Path",
      keyPath: "accessibilityPath",
      reviewable: self))
    attributes[.accessibility]?.append(DesignReviewMutableAttribute(
      title: "Frame",
      keyPath: "accessibilityFrame",
      reviewable: self))

    // build list for interactivity
    attributes[.general] = [DesignReviewInspectorAttribute]()
    attributes[.general]?.append(DesignReviewMutableAttribute(
      title: "User Interaction Enabled",
      keyPath: "userInteractionEnabled",
      reviewable: self,
      modifier: { [weak self] newValue, _ in
        guard let self = self,
          let newBool = newValue as? Bool else {
            return
        }

        self.isUserInteractionEnabled = newBool
      }))
    attributes[.general]?.append(DesignReviewMutableAttribute(
      title: "Multiple Touch Enabled",
      keyPath: "multipleTouchEnabled",
      reviewable: self,
      modifier: { [weak self] newValue, _ in
        guard let self = self,
          let newBool = newValue as? Bool else {
            return
        }

        self.isMultipleTouchEnabled = newBool
      }))
    attributes[.general]?.append(DesignReviewMutableAttribute(
      title: "Exclusive Touch",
      keyPath: "exclusiveTouch",
      reviewable: self))

    // build list for visuals
    attributes[.styling] = [DesignReviewInspectorAttribute]()
    attributes[.generalLayout] = [DesignReviewInspectorAttribute]()

    attributes[.styling]?.append(DesignReviewMutableAttribute(
      title: "Background Color",
      keyPath: "backgroundColor",
      reviewable: self,
      modifier: { [weak self] newValue, _ in
        guard let self = self,
          let newColor = newValue as? UIColor else {
            return
        }

        self.backgroundColor = newColor
      }))

    attributes[.styling]?.append(DesignReviewMutableAttribute(
      title: "Corner Radius",
      keyPath: "layer.cornerRadius",
      reviewable: self,
      modifier: { [weak self] newValue, _ in
        guard let self = self,
          let rawRadius = newValue as? Double else {
            return
        }

        self.layer.cornerRadius = CGFloat(rawRadius)
      }))
    attributes[.styling]?.append(DesignReviewEnumAttribute<UIView.TintAdjustmentMode>(
      title: "Tint Adjustment Mode",
      keyPath: "tintAdjustmentMode",
      reviewable: self))
    attributes[.styling]?.append(DesignReviewMutableAttribute(
      title: "Tint Color",
      keyPath: "tintColor",
      reviewable: self,
      modifier: { [weak self] newValue, _ in
        guard let self = self,
          let newColor = newValue as? UIColor else {
            return
        }

        self.tintColor = newColor
      }))

    attributes[.styling]?.append(DesignReviewMutableAttribute(
      title: "Opacity",
      keyPath: "alpha",
      reviewable: self,
      modifier: { [weak self] newValue, _ in
        guard let self = self,
          let rawAlpha = newValue as? Double else {
            return
        }

        self.alpha = CGFloat(rawAlpha)
      },
      modifierIncrementSize: 0.1,
      modifierRange: 0.1...1))

    attributes[.generalLayout]?.append(DesignReviewEnumAttribute<UIView.ContentMode>(
      title: "Content Mode",
      keyPath: "contentMode",
      reviewable: self,
      modifier: { [weak self] newValue, _ in
        guard let self = self,
          let newContentMode = newValue as? UIView.ContentMode else {
            return
        }

        self.contentMode = newContentMode
      }))

    attributes[.generalLayout]?.append(DesignReviewMutableAttribute(
      title: "Safe Area Insets",
      keyPath: "safeAreaInsets",
      reviewable: self))

    attributes[.constraints] = [DesignReviewInspectorAttribute]()
    attributes[.constraints]?.append(DesignReviewImmutableAttribute(
      title: "Uses AutoLayout?",
      keyPath: "translatesAutoresizingMaskIntoConstraints",
      value: !translatesAutoresizingMaskIntoConstraints))
    attributes[.constraints]?.append(DesignReviewMutableAttribute(
      title: "Has Ambiguous Layout?",
      keyPath: "hasAmbiguousLayout",
      reviewable: self))

    if !translatesAutoresizingMaskIntoConstraints {
      for constraint in actualRelatedConstraints {
        attributes[.constraints]?.append(DesignReviewImmutableAttribute(
          title: constraint.summaryDisplayName,
          keyPath: "horizontalConstraints",
          value: constraint))
      }
    }

    attributes[.contentHugging] = [DesignReviewInspectorAttribute]()
    attributes[.contentHugging]?.append(DesignReviewImmutableAttribute(
      title: "Horizontal Priority",
      keyPath: "horizontalContentHuggingPriority",
      value: contentHuggingPriority(for: .horizontal)))
    attributes[.contentHugging]?.append(DesignReviewImmutableAttribute(
      title: "Vertical Priority",
      keyPath: "verticalContentHuggingPriority",
      value: contentHuggingPriority(for: .vertical)))

    attributes[.compressionResistance] = [DesignReviewInspectorAttribute]()
    attributes[.compressionResistance]?.append(DesignReviewImmutableAttribute(
      title: "Horizontal Priority",
      keyPath: "horizontalContentCompressionResistance",
      value: contentCompressionResistancePriority(for: .horizontal)))
    attributes[.compressionResistance]?.append(DesignReviewImmutableAttribute(
      title: "Vertical Priority",
      keyPath: "verticalContentCompressionResistance",
      value: contentCompressionResistancePriority(for: .vertical)))

    // special field for UIImageViews

    if self is UIImageView {
      attributes[.styling]?.append(DesignReviewMutableAttribute(
        title: "Image",
        keyPath: "image",
        reviewable: self))
    }

    // special fields for UILabels

    if self is UILabel {
      attributes[.typography] = [DesignReviewInspectorAttribute]()

      attributes[.typography]?.append(DesignReviewMutableAttribute(
        title: "Text",
        keyPath: "text",
        reviewable: self,
        modifier: { [weak self] newValue, _ in
          guard let self = self,
            let newText = newValue as? String else {
              return
          }

          if let button = self.superview as? UIButton {
            button.setTitle(newText, for: .normal)
            (self as? UILabel)?.text = newText
            return
          }

          (self as? UILabel)?.text = newText
        },
      shouldModifyViaAlert: true))

      attributes[.typography]?.append(DesignReviewMutableAttribute(
        title: "Attributed Text",
        keyPath: "attributedText",
        reviewable: self,
        modifier: { [weak self] newValue, _ in
          guard let self = self,
            let newText = newValue as? String,
            let currentString = (self as? UILabel)?.attributedText as? NSMutableAttributedString else {
              return
          }

          currentString.mutableString.setString(newText)
          (self as? UILabel)?.attributedText = currentString
        },
      shouldModifyViaAlert: true))

      attributes[.typography]?.append(DesignReviewEnumAttribute<NSLineBreakMode>(
        title: "LineBreakMode",
        keyPath: "lineBreakMode",
        reviewable: self,
        modifier: { [weak self] newValue, _ in
          guard let self = self,
            let newBreakMode = newValue as? NSLineBreakMode else {
              return
          }

          (self as? UILabel)?.lineBreakMode = newBreakMode
        }))

      attributes[.typography]?.append(DesignReviewEnumAttribute<NSTextAlignment>(
        title: "Text Alignment",
        keyPath: "textAlignment",
        reviewable: self,
        modifier: { [weak self] newValue, _ in
          guard let self = self,
            let newAlignment = newValue as? NSTextAlignment else {
              return
          }

          (self as? UILabel)?.textAlignment = newAlignment
        }))

      attributes[.typography]?.append(DesignReviewMutableAttribute(
        title: "Text Color",
        keyPath: "textColor",
        reviewable: self,
        modifier: { [weak self] newValue, _ in
          guard let self = self,
            let newColor = newValue as? UIColor else {
              return
          }

          (self as? UILabel)?.textColor = newColor
        }))
      attributes[.typography]?.append(DesignReviewMutableAttribute(
        title: "Font",
        keyPath: "font",
        reviewable: self))
      attributes[.typography]?.append(DesignReviewMutableAttribute(
        title: "Number Of Lines",
        keyPath: "numberOfLines",
        reviewable: self,
        modifier: { [weak self] newValue, _ in
          guard let self = self,
            let rawLineCount = newValue as? Double else {
              return
          }

          (self as? UILabel)?.numberOfLines = Int(rawLineCount)
        },
      modifierIncrementSize: 1))
    }

    // special fields for UIStackViews

    if self is UIStackView {
      attributes[.styling]?.append(DesignReviewEnumAttribute<UIStackView.Alignment>(
        title: "Stack Alignment",
        keyPath: "alignment",
        reviewable: self,
        modifier: { [weak self] newValue, _ in
          guard let self = self,
            let newAlignment = newValue as? UIStackView.Alignment else {
              return
          }

          (self as? UIStackView)?.alignment = newAlignment
        }))

      attributes[.styling]?.append(DesignReviewEnumAttribute<NSLayoutConstraint.Axis>(
        title: "Stack Axis",
        keyPath: "axis",
        reviewable: self,
        modifier: { [weak self] newValue, _ in
          guard let self = self,
            let newAxis = newValue as? NSLayoutConstraint.Axis else {
              return
          }

          (self as? UIStackView)?.axis = newAxis
        }))

      attributes[.styling]?.append(DesignReviewEnumAttribute<UIStackView.Distribution>(
        title: "Stack Distribution",
        keyPath: "distribution",
        reviewable: self,
        modifier: { [weak self] newValue, _ in
          guard let self = self,
            let newDistribution = newValue as? UIStackView.Distribution else {
              return
          }

          (self as? UIStackView)?.distribution = newDistribution
        }))

      attributes[.styling]?.append(DesignReviewMutableAttribute(
        title: "Stack Spacing",
        keyPath: "spacing",
        reviewable: self,
        modifier: { [weak self] newValue, _ in
          guard let self = self,
            let rawSpacing = newValue as? Double else {
              return
          }
          (self as? UIStackView)?.spacing = CGFloat(rawSpacing)
        }))
    }

    return attributes
  }
}
