//
//  CGPoint+Offset.swift
//  
//
//  Created by Alexander Lee on 2022-08-07.
//

import CoreGraphics

extension CGPoint {
  func offset(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
    CGPoint(x: self.x + x, y: self.y + y)
  }
}
