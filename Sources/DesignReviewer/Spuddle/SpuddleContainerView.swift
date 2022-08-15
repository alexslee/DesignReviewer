//
//  SpuddleContainerView.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Combine
import Foundation
import SwiftUI

struct SpuddleContainerView: View {
  @ObservedObject var viewModel: SpuddlePresentedViewModel

  var body: some View {
    ZStack {
      ForEach(viewModel.spuddles) { spuddle in
        ZStack(alignment: .topLeading) {
          spuddle.backgroundView

          spuddle.view
            .opacity(spuddle.viewModel.currentSize != nil ? 1 : 0)
            .trackSize(accountingFor: spuddle.viewModel.currentTransaction, sizeDidChange: { newSize in
              if let currentTransaction = spuddle.viewModel.currentTransaction,
                 let currentSize = spuddle.viewModel.currentSize {
                if currentSize != newSize {
                  spuddle.respondToSizeChange(newSize)
                  viewModel.refreshAll()
                } else {
                  withTransaction(currentTransaction) {
                    spuddle.respondToSizeChange(newSize)
                    viewModel.refreshAll()
                  }
                }

                spuddle.viewModel.currentTransaction = nil
              } else {
                spuddle.respondToSizeChange(newSize)
                viewModel.refreshAll()
              }
            })
            .offset(offset(for: spuddle))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.asymmetric(insertion: spuddle.viewModel.transition, removal: .opacity)) // TODO: dismissal transition
      }
    }
    .edgesIgnoringSafeArea(.all)
  }

  private func offset(for spuddle: Spuddle) -> CGSize {
    guard spuddle.viewModel.currentSize != nil else { return .zero }

    return CGSize(
      width: spuddle.viewModel.staticFrame.origin.x,
      height: spuddle.viewModel.staticFrame.origin.y)
  }
}
