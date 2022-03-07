//
//  NSString+DesignReviewable.swift
//  
//
//  Created by Alex Lee on 3/4/22.
//

import UIKit

extension NSString: DesignReviewable {
  func createReviewableAttributes() -> [DesignReviewInspectorAttributeGroup: [DesignReviewInspectorAttribute]] {
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

    return attributes
  }
}
