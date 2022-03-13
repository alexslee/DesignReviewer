//
//  NSString+DesignReviewable.swift
//  
//
//  Created by Alex Lee on 3/12/22.
//

import UIKit

extension NSString: DesignReviewable {
  public func createReviewableAttributes() -> [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]] {
    var attributes = [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]]()

    let view = UILabel()
    view.numberOfLines = 0
    view.backgroundColor = .clear
    view.font = .body
    view.text = self as String
    view.textColor = .monochrome5

    view.frame.size = view.sizeThatFits(CGSize(width: 320, height: CGFloat.greatestFiniteMagnitude))

    let screenshot = DesignReviewImageCapturer(size: view.bounds.size).image(actions: { context in
      view.drawHierarchy(in: context.config.bounds, afterScreenUpdates: true)
    })
    if !screenshot.size.equalTo(.zero) {
      attributes[.screenshot] = [DesignReviewInspectorAttribute]()
      attributes[.screenshot]?.append(DesignReviewScreenshotAttribute(image: screenshot))
    }

    attributes[.general] = [DesignReviewInspectorAttribute]()
    attributes[.general]?.append(DesignReviewImmutableAttribute(
      title: "Change text by long pressing me on the previous page!",
      keyPath: "nada",
      value: ""))

    return attributes
  }
}
