//
//  SpuddleOptionsModifierViewModel.swift
//  
//
//  Created by Alexander Lee on 2022-08-18.
//

import Foundation

enum SpuddleModifierViewModel {
  case option(viewModel: SpuddleOptionsModifierViewModel)
  case stepper(viewModel: SpuddleStepperModifierViewModel)
  case text(viewModel: SpuddleTextModifierViewModel)
}

class SpuddleOptionsModifierViewModel: ObservableObject {
  struct Option: Identifiable {
    let id: UUID
    let name: String
    var isSelected: Bool
  }

  private var initialOption: DesignReviewAttributeOptionSelectable?
  private let internalOptions: [DesignReviewAttributeOptionSelectable]
  private var selectedOptionIndex: Int?

  @Published private(set) var options = [Option]()
  @Published var shouldDismiss = false

  var changeHandler: ((Any) -> Void)?
  var dismissHandler: (() -> Void)?
  let title: String

  init(options: [DesignReviewAttributeOptionSelectable],
       initialOption: DesignReviewAttributeOptionSelectable?,
       title: String,
       changeHandler: ((Any) -> Void)? = nil,
       dismissHandler: (() -> Void)? = nil) {
    self.internalOptions = options
    self.initialOption = initialOption
    self.title = title
    self.changeHandler = changeHandler
    self.dismissHandler = dismissHandler

    mapToSpuddlyOptions()
  }

  /// preview init
  init(options: [Option], title: String) {
    self.internalOptions = []
    self.options = options
    self.title = title
  }

  func select(_ optionID: UUID) {
    guard let optionIndex = options.firstIndex(where: { $0.id == optionID }) else { return }
    changeHandler?(internalOptions[optionIndex])

    selectedOptionIndex = optionIndex
    mapToSpuddlyOptions()
  }

  func resetChoice() {
    changeHandler?(initialOption as Any)
    selectedOptionIndex = nil
    mapToSpuddlyOptions()
  }

  private func mapToSpuddlyOptions() {
    var newOptions = [Option]()

    if let selectedOptionIndex = selectedOptionIndex {
      for (index, option) in options.enumerated() {
        if index == selectedOptionIndex {
          newOptions.append(Option(id: option.id, name: option.name, isSelected: true))
        } else {
          newOptions.append(Option(id: option.id, name: option.name, isSelected: false))
        }
      }
    } else {
      for option in internalOptions {
        if option.displayName == initialOption?.displayName {
          newOptions.append(Option(id: UUID(), name: option.displayName, isSelected: true))
        } else {
          newOptions.append(Option(id: UUID(), name: option.displayName, isSelected: false))
        }
      }
    }

    options = newOptions
  }
}
