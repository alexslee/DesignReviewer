//
//  UIColor+DesignReviewable.swift
//
//
//  Created by Alex Lee on 3/4/22.
//

import Foundation
import UIKit

extension UIColor: DesignReviewable {
  private static let previewImageHeight: CGFloat = 666 / 6 // 😈

  func createReviewableAttributes() -> [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]] {
    var attributes = [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]]()

    // start with the preview screenshot
    if cgColor.pattern != nil || (self != .clear && cgColor.alpha != 0) {
      attributes[.preview] = [DesignReviewInspectorAttribute]()

      // defining some kinda-sorta-not-totally arbitrary dimensions just to draw the color into.
      let size = CGSize(width: UIScreen.main.bounds.width, height: Self.previewImageHeight)

      let screenshot = DesignReviewImageCapturer(size: size).image { context in
        setFill()
        UIRectFill(context.config.bounds)
      }

      attributes[.preview]?.append(DesignReviewPreviewAttribute(image: screenshot))
    }

    // throw everything else into the General section for now
    attributes[.general] = [DesignReviewInspectorAttribute]()
    if self == .clear {
      attributes[.general]?.append(DesignReviewImmutableAttribute(
        title: "Color",
        keyPath: "self",
        value: "Clear"))
    }

    attributes[.general]?.append(DesignReviewImmutableAttribute(
      title: "Hex String",
      keyPath: "hexString",
      value: hexString))

    attributes[.general]?.append(DesignReviewImmutableAttribute(
      title: "Change color by long pressing me on the previous page! (iOS 14+)",
      keyPath: "nada",
      value: ""))

    return attributes
  }
}
