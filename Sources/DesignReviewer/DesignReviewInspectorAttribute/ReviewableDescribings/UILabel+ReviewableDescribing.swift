//
//  UILabel+ReviewableDescribing.swift
//  
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension NSLineBreakMode: ReviewableDescribing {
  public static var allCases: [NSLineBreakMode] = {
    return [.byCharWrapping, .byClipping, .byTruncatingHead,
            .byTruncatingTail, .byTruncatingMiddle, .byWordWrapping]
  }()

  public var displayName: String {
    switch self {
    case .byCharWrapping:
      return "By Char Wrapping"
    case .byClipping:
      return "By Clipping"
    case .byTruncatingHead:
      return "By Truncating Head"
    case .byTruncatingTail:
      return "By Truncating Tail"
    case .byTruncatingMiddle:
      return "By Truncating Middle"
    case .byWordWrapping:
      return "By Word Wrapping"
    @unknown default:
      return "Unknown"
    }
  }
}

extension NSTextAlignment: ReviewableDescribing {
  public static var allCases: [NSTextAlignment] = {
    return [.center, .justified, .left, .natural, .right]
  }()

  public var displayName: String {
    switch self {
    case .center:
      return "Center"
    case .justified:
      return "Justified"
    case .left:
      return "Left"
    case .natural:
      return "Natural"
    case .right:
      return "Right"
    @unknown default:
      return "Unknown"
    }
  }
}
