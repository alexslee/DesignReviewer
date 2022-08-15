//
//  UIViewController+Extensions.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import UIKit

extension UIViewController {
  func present(_ spuddle: Spuddle) {
    guard let currentWindow = view.window else { return }
    spuddle.present(in: currentWindow)
  }
}
