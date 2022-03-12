//
//  UIImage+ReviewableDescribing.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension UIImage.RenderingMode: ReviewableDescribing, CaseIterable {
  public static var allCases: [UIImage.RenderingMode] {
    return [.alwaysOriginal, .alwaysTemplate, .automatic]
  }

  public var displayName: String {
    switch self {
    case .alwaysOriginal:
      return "Always Original"
    case .alwaysTemplate:
      return "Always Template"
    case .automatic:
      return "Automatic"
    @unknown default:
      return "Unknown"
    }
  }
}
