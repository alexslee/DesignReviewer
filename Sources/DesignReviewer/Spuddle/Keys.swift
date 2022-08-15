//
//  Keys.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import SwiftUI
import UIKit

struct ContentSizeReaderPreferenceKey: PreferenceKey {
  static var defaultValue: CGSize { return CGSize() }
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

extension EnvironmentValues {
  // Designates the `UIWindow` hosting the views within the current environment.
  var window: UIWindow? {
    get {
      self[WindowEnvironmentKey.self]
    }
    set {
      self[WindowEnvironmentKey.self] = newValue
    }
  }

  private struct WindowEnvironmentKey: EnvironmentKey {
    typealias Value = UIWindow?
    static var defaultValue: UIWindow? = nil
  }
}
