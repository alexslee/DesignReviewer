//
//  SpuddleStepperModifierViewModel.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Combine
import Foundation

class SpuddleStepperModifierViewModel: ObservableObject {
  let attribute: any DesignReviewInspectorAttribute
  private let incrementSize: CGFloat
  private let minimumValue: CGFloat
  private let maximumValue: CGFloat
  @Published private(set) var currentValue: Double

  @Published var shouldDismiss = false

  var changeHandler: ((Any) -> Void)?

  var dismissHandler: (() -> Void)?

  init(attribute: any DesignReviewInspectorAttribute,
       changeHandler: ((Any) -> Void)? = nil,
       dismissHandler: (() -> Void)? = nil) {
    self.attribute = attribute
    self.changeHandler = changeHandler
    self.dismissHandler = dismissHandler

    let numberValue = attribute.value as? Double
    assert(numberValue != nil)

    currentValue = numberValue!

    if let mutableAttribute = attribute as? DesignReviewMutableAttribute {
      incrementSize = mutableAttribute.modifierIncrementSize
      minimumValue = mutableAttribute.modifierRange?.lowerBound ?? -.infinity
      maximumValue = mutableAttribute.modifierRange?.upperBound ?? .infinity
    } else {
      incrementSize = .extraExtraSmall
      minimumValue = -.infinity
      maximumValue = .infinity
    }
  }

  func handleDecrement() {
    if currentValue - incrementSize < minimumValue {
      changeHandler?(currentValue)
    } else {
      currentValue -= incrementSize
      changeHandler?(currentValue)
    }
  }

  func handleIncrement() {
    if currentValue + incrementSize > maximumValue {
      changeHandler?(currentValue)
    } else {
      currentValue += incrementSize
      changeHandler?(currentValue)
    }
  }
}
