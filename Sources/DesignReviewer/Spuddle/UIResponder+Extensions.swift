//
//  UIResponder+Extensions.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import UIKit

extension UIResponder {
  var spuddlePresentedViewModel: SpuddlePresentedViewModel {
    if let superView = (self as? UIView)?.superview { return superView.spuddlePresentedViewModel }
    if let window = self as? UIWindow { return SpuddleWindowManager.shared.viewModel(for: window) }
    if let viewController = self as? UIViewController { return viewController.view.spuddlePresentedViewModel }

    // ya goofed it if it hit here
    return SpuddlePresentedViewModel()
  }
}
