//
//  SpuddleTextModifierView.swift
//  
//
//  Created by Alexander Lee on 2022-08-18.
//

import SwiftUI

struct SpuddleTextModifierView: View {
  @ObservedObject var viewModel: SpuddleTextModifierViewModel

  var body: some View {
    VStack(spacing: .medium) {
      Text("Edit")
        .font(.system(size: .extraLarge))
        .fontWeight(.heavy)

      Text("\(viewModel.title)")
        .font(.system(size: .large))
        .bold()

      TextEditor(text: $viewModel.currentValue)
        .frame(maxHeight: 160)

      HStack(spacing: .extraSmall) {
        Button(action: {
          viewModel.shouldDismiss = true
        }, label: {
          Text("Alrighty")
        })
        .buttonStyle(DesignReviewerPrimaryButtonStyle())

        Button(action: {
          viewModel.resetChoice()
          viewModel.shouldDismiss = true
        }, label: {
          Text("No thanks")
        })
        .buttonStyle(DesignReviewerSecondaryButtonStyle())
      }
    }
    .padding(.large)
    .background(VisualEffecter(.systemMaterial))
    .cornerRadius(.medium)
    .padding()
    .onChange(of: viewModel.shouldDismiss) { newValue in
      guard newValue else { return }
      viewModel.dismissHandler?()
    }
  }
}

struct SpuddleTextModifierView_Previews: PreviewProvider {
    static var previews: some View {
      SpuddleTextModifierView(viewModel: SpuddleTextModifierViewModel(initialValue: "retLock", title: "Dummy"))
    }
}
