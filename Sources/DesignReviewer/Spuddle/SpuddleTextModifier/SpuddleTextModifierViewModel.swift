//
//  SpuddleTextModifierViewModel.swift
//  
//
//  Created by Alexander Lee on 2022-08-18.
//

import Foundation
import SwiftUI

class SpuddleTextModifierViewModel: ObservableObject {
  let initialValue: String
  let title: String

  @Published var shouldDismiss = false

  var currentValue: String {
    didSet {
      changeHandler?(currentValue)
    }
  }

  var changeHandler: ((Any) -> Void)?
  var dismissHandler: (() -> Void)?

  init(initialValue: String,
       title: String,
       changeHandler: ((Any) -> Void)? = nil,
       dismissHandler: (() -> Void)? = nil) {
    self.initialValue = initialValue
    self.title = title
    self.changeHandler = changeHandler
    self.dismissHandler = dismissHandler

    currentValue = initialValue
  }

  func resetChoice() {
    currentValue = initialValue
  }
}
