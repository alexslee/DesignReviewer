//
//  SpuddlePlacement.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import CoreGraphics

enum SpuddlePlacement {
  case topLeft, top, topRight, centerLeft, center, centerRight, bottomLeft, bottom, bottomRight
  static func calculateRelativePosition(for placement: SpuddlePlacement,
                                        in containerFrame: CGRect,
                                        with spuddleSize: CGSize) -> CGRect {
    let newOrigin = relativeOrigin(for: placement, in: containerFrame, with: spuddleSize)
    return CGRect(origin: newOrigin, size: spuddleSize)
  }

  static func relativeOrigin(for placement: SpuddlePlacement,
                             in containerFrame: CGRect,
                             with spuddleSize: CGSize) -> CGPoint {
    switch placement {
    case .topLeft:
      return CGPoint(x: containerFrame.origin.x, y: containerFrame.origin.y)
    case .top:
      return CGPoint(x: containerFrame.origin.x + ((containerFrame.width - spuddleSize.width) / 2),
                     y: containerFrame.origin.y)
    case .topRight:
      return CGPoint(x: containerFrame.origin.x + containerFrame.width - spuddleSize.width,
                     y: containerFrame.origin.y)
    case .centerLeft:
      return CGPoint(x: containerFrame.origin.x,
                     y: containerFrame.origin.y + ((containerFrame.height - spuddleSize.height) / 2))
    case .center:
      return CGPoint(x: containerFrame.origin.x + ((containerFrame.width - spuddleSize.width) / 2),
                     y: containerFrame.origin.y + ((containerFrame.height - spuddleSize.height) / 2))
    case .centerRight:
      return CGPoint(x: containerFrame.origin.x + containerFrame.width - spuddleSize.width,
                     y: containerFrame.origin.y + ((containerFrame.height - spuddleSize.height) / 2))
    case .bottomLeft:
      return CGPoint(x: containerFrame.origin.x,
                     y: containerFrame.origin.y + containerFrame.height - spuddleSize.height)
    case .bottom:
      return CGPoint(x: containerFrame.origin.x + ((containerFrame.width - spuddleSize.width) / 2),
                     y: containerFrame.origin.y + containerFrame.height - spuddleSize.height)
    case .bottomRight:
      return CGPoint(x: containerFrame.origin.x + containerFrame.width - spuddleSize.width,
                     y: containerFrame.origin.y + containerFrame.height - spuddleSize.height)
    }
  }
}
