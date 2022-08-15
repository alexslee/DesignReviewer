//
//  SpuddleStepperModiferView.swift
//  
//
//  Created by Alexander Lee on 2022-08-14.
//

import Combine
import os.log
import SwiftUI
import UIKit

struct VisualEffecter: UIViewRepresentable {
  /// The blur's style.
  public var style: UIBlurEffect.Style

  /// Use UIKit blurs in SwiftUI.
  public init(_ style: UIBlurEffect.Style) {
    self.style = style
  }

  public func makeUIView(context _: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
    UIVisualEffectView()
  }

  public func updateUIView(_ uiView: UIVisualEffectView, context _: UIViewRepresentableContext<Self>) {
    uiView.effect = UIBlurEffect(style: style)
  }
}

struct SpuddleStepperModiferView: View {
  @ObservedObject var viewModel: SpuddleStepperModifierViewModel

  var body: some View {
    VStack(spacing: .medium) {
      HStack {
        Spacer()

        Button (action: {
        }, label: {
          Image(systemName: "xmark")
            .font(.system(size: .medium))
            .foregroundColor(.secondary)
            .frame(width: .extraLarge, height: .extraLarge)
            .background(Color(.systemBackground))
            .cornerRadius(.medium)
        })
      }

      Text("Edit")
        .font(.system(size: .extraLarge))
        .bold()

      Text("Current value: \(viewModel.currentValue)")

      Stepper("Stepper",
              onIncrement: {
        viewModel.handleIncrement()
      }, onDecrement: {
        viewModel.handleDecrement()
      })
        .labelsHidden()
    }
    .padding(.large)
    .background(VisualEffecter(.systemMaterial))
    .cornerRadius(.medium)
    .padding()
  }
}

// MARK: - Preview Helpers

private var globalDummyNumber: CGFloat = 32

extension UILabel {
  @objc dynamic var dummyNumber: CGFloat {
    get {
      return globalDummyNumber
    }
    set {
      globalDummyNumber = newValue
    }
  }
}

struct SpuddleStepperModiferView_Previews: PreviewProvider {
  private static var numAttr = DesignReviewMutableAttribute(
    title: "Dummy num try",
    keyPath: "dummyNumber",
    reviewable: label,
    modifier: { newValue, _ in
      guard let newRawValue = newValue as? CGFloat else {
        os_log("number callback triggered, value is nil")
        return
      }

      globalDummyNumber = newRawValue
    },
    modifierRange: 8...64)
  private static var mockViewModel = SpuddleStepperModifierViewModel(attribute: numAttr)

  private static let label = UILabel()

  static var previews: some View {
    SpuddleStepperModiferView(viewModel: mockViewModel)
      .padding()
      .previewLayout(.sizeThatFits)
  }
}
