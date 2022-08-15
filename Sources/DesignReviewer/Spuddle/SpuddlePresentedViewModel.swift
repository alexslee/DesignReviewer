//
//  SpuddlePresentedViewModel.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import Combine

/// Oversees all spuddles for a given window. Intended to be managed by `SpuddleWindowManager`
class SpuddlePresentedViewModel: ObservableObject {
  @Published var spuddles = [Spuddle]()

  func refreshAll() { objectWillChange.send() }
}
