//
//  View+Extensions.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Foundation
import SwiftUI

extension View {
  /// Convenience view builder that applies the provided transform if a given bool evaluates to true.
  @ViewBuilder
  func apply<T: View>(_ block: (Self) -> T, if condition: Bool) -> some View {
    if condition {
      block(self)
    } else {
      self
    }
  }

  /**
   Convenience wrapper around `GeometryReader` to receive word whenever the view's size is updated (includes rotation).
   h/t to https://stackoverflow.com/a/66822461/14351818
   */
  func trackSize(accountingFor transaction: Transaction? = nil, sizeDidChange: @escaping (CGSize) -> Void) -> some View {
    return background(
      GeometryReader { proxy in
        Color.clear
          .preference(key: ContentSizeReaderPreferenceKey.self, value: proxy.size)
          .onPreferenceChange(ContentSizeReaderPreferenceKey.self) { newValue in
            DispatchQueue.main.async { sizeDidChange(newValue) }
          }
          .onChange(of: transaction?.animation, perform: { _ in // rotation detection
            DispatchQueue.main.async { sizeDidChange(proxy.size) }
          })
      }
        .hidden())
  }
}
