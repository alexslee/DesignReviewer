//
//  SpuddleContainerView.swift
//  
//
//  Created by Alexander Lee on 2022-08-15.
//

import Combine
import Foundation
import SwiftUI

extension CGPoint {
  static func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
  }

  static func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
  }
}

/// Holds the spuddle view and provides support for drag gesture + snapping-to-position when it ends
struct SpuddleContainerView: View {
  @ObservedObject var viewModel: SpuddlePresentedViewModel
  @State private var spuddleOffset: CGSize = .zero
  @State var selectedSpuddle: Spuddle? = nil

  var body: some View {
    ZStack {
      ForEach(viewModel.spuddles) { spuddle in
        ZStack(alignment: .topLeading) {
          spuddle.backgroundView
            .transaction({ $0.animation = nil }) // TODO: control bg animation separately. disabled for now

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
            .simultaneousGesture(
              DragGesture(minimumDistance: .extraExtraSmall)
                .onChanged({ value in
                  func update() {
                    dragOffset(value.translation, spuddle: spuddle)
                    spuddle.viewModel.currentFrame = CGRect(
                      origin: spuddle.viewModel.staticFrame.origin + CGPoint(x: spuddleOffset.width, y: spuddleOffset.height),
                      size: spuddle.viewModel.currentSize ?? .zero)
                  }

                  if selectedSpuddle == nil {
                    withAnimation(.spuddleSpringyDefault) {
                      selectedSpuddle = spuddle
                      update()
                    }
                  } else {
                    update() // drag already in progress
                  }
                })
                .onEnded({ value in
                  let finalOrigin = CGPoint(
                    x: spuddle.viewModel.staticFrame.origin.x + value.predictedEndTranslation.width,
                    y: spuddle.viewModel.staticFrame.origin.y + value.predictedEndTranslation.height)

                  withAnimation(.spuddleSpringyDefault) {
                    spuddleOffset = .zero
                    spuddle.positionDidChange(to: finalOrigin)
                    spuddle.viewModel.currentFrame = spuddle.viewModel.staticFrame
                  }

                  selectedSpuddle = nil
                })
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.asymmetric(insertion: spuddle.viewModel.transition, removal: spuddle.viewModel.dismissTransition))
        .onDisappear(perform: { spuddle.viewModel.onContainerDisappear?() })
      }
    }
    .edgesIgnoringSafeArea(.all)
  }

  private func dragOffset(_ offset: CGSize, spuddle: Spuddle) {
    var newSpuddleOffset = CGSize.zero

    let didDragTheOtherWay = offset.height <= 0
    if didDragTheOtherWay {
      newSpuddleOffset.height = getRubberBanding(translation: offset).height
    } else {
      newSpuddleOffset.height = offset.height
    }

    spuddleOffset = newSpuddleOffset
  }

  private func getRubberBanding(translation: CGSize) -> CGSize {
    var retVal = CGSize.zero
    retVal.width = pow(abs(translation.width), 0.7) * (translation.width > 0 ? 1 : -1)
    retVal.height = pow(abs(translation.height), 0.7) * (translation.height > 0 ? 1 : -1)
    return retVal
  }

  private func offset(for spuddle: Spuddle) -> CGSize {
    guard spuddle.viewModel.currentSize != nil else { return .zero }

    return CGSize(
      width: spuddle.viewModel.staticFrame.origin.x + (selectedSpuddle == spuddle ? spuddleOffset.width : 0),
      height: spuddle.viewModel.staticFrame.origin.y + (selectedSpuddle == spuddle ? spuddleOffset.height : 0))
  }
}
