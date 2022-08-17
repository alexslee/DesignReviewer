//
//  Animation+Extensions.swift
//
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import SwiftUI

extension Animation {
  /// Just springy enough to be annoying
  static var spuddleSpringyDefault: Animation {
    .spring(response: 0.5, dampingFraction: 0.65, blendDuration: 0.0)
  }
}
