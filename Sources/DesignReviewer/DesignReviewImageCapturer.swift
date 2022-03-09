//
//  DesignReviewImageCapturer.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

/// Represents an image capturer configuration. Downstream, these values used to configure the
/// environment in which the image will be drawn.
struct DesignReviewImageCapturerConfig {
  /// Bounds of the context within which the image will be drawn.
  var bounds: CGRect = .zero

  /// Whether or not the resulting image will be opaque
  var isOpaque = true

  /// The scale of the resulting image.
  var scale: CGFloat
}

/// Represents the state of the current `DesignReviewImageCapturer`.
class DesignReviewImageCapturerContext {
  /// The renderer's associated `CGContext`
  let cgContext: CGContext

  /// The config that describes the bounds, opaqueness, and scale of the graphics context.
  let config: DesignReviewImageCapturerConfig

  /// The `UIImage` representing the current state of the image renderer's `CGContext`, or
  /// empty if an image failed to be drawn.
  var currentImage: UIImage {
    return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
  }

  init(config: DesignReviewImageCapturerConfig, cgContext: CGContext) {
    self.config = config
    self.cgContext = cgContext
  }
}

/// Represents an image capturer used for outputting arbitrary contents into a `UIImage`.
class DesignReviewImageCapturer {
  let config: DesignReviewImageCapturerConfig

  convenience init(bounds: CGRect) {
    self.init(size: bounds.size, config: nil)
  }

  init(size: CGSize, config: DesignReviewImageCapturerConfig? = nil) {
    let bounds = CGRect(origin: .zero, size: size)
    let isOpaque = config?.isOpaque ?? false
    let scale = config?.scale ?? UIScreen.main.scale

    self.config = DesignReviewImageCapturerConfig(bounds: bounds, isOpaque: isOpaque, scale: scale)
  }

  /**
   Renders an image within the current context, utilizing the provided actions.

   - Parameters:
     - actions: Any actions you wish to perform while the graphics context is open.

   - Returns:
     A new `UIImage` (will be blank if the attempt to draw failed).
   */
  func image(actions: (DesignReviewImageCapturerContext) -> Void) -> UIImage {
    var image: UIImage?

    draw(actions, postActionsExecution: { rendererContext in
      image = rendererContext.currentImage
    })

    return image ?? UIImage()
  }

  /**
   Spins up a `CGContext` using the provided configuration params, in order to render an image. Takes
   into account any provided actions while the context is open.
   */
  private func draw(_ actions: (DesignReviewImageCapturerContext) -> Void,
                    postActionsExecution: ((DesignReviewImageCapturerContext) -> Void)? = nil) {
    UIGraphicsBeginImageContextWithOptions(config.bounds.size, config.isOpaque, config.scale)

    guard let cgContext = UIGraphicsGetCurrentContext() else {
      UIGraphicsEndImageContext()
      return
    }

    let context = DesignReviewImageCapturerContext(config: config, cgContext: cgContext)

    actions(context)
    postActionsExecution?(context)

    UIGraphicsEndImageContext()
  }
}
