//
//  SpuddleOptionsModifierView.swift
//  
//
//  Created by Alexander Lee on 2022-08-17.
//

import SwiftUI

struct DesignReviewerPrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    let backgroundColor = configuration.isPressed ? Color(UIColor.primary4) : Color(UIColor.primary3)


    configuration.label
      .foregroundColor(Color(UIColor.monochrome0))
      .padding([.top, .bottom], .extraExtraSmall)
      .frame(maxWidth: .infinity, minHeight: 52)
      .background(backgroundColor)
      .cornerRadius(.extraExtraSmall)
  }
}

struct DesignReviewerSecondaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    let backgroundColor = configuration.isPressed ? Color(UIColor.primary1) : Color(UIColor.monochrome0)

    configuration.label
      .foregroundColor(Color(UIColor.monochrome5))
      .padding([.top, .bottom], .extraExtraSmall)
      .frame(maxWidth: .infinity, minHeight: 52)
      .background(backgroundColor)
      .cornerRadius(.extraExtraSmall)
      .overlay(
        RoundedRectangle(cornerRadius: .extraExtraSmall)
          .stroke(Color(UIColor.primary3))
      )
  }
}

struct SpuddleOptionsModifierView: View {
  @ObservedObject var viewModel: SpuddleOptionsModifierViewModel

  var body: some View {
    VStack(spacing: .small) {
      Text("Edit")
        .font(.system(size: .extraLarge))
        .fontWeight(.heavy)

      Text("\(viewModel.title)")
        .font(.system(size: .large))
        .bold()

      ZStack(alignment: .bottom) {
        ScrollView(showsIndicators: true) {
          LazyVStack(spacing: 0) {
            ForEach(viewModel.options) { option in
              VStack {
                HStack {
                  Text(option.name)
                    .apply({ label in label.bold() }, if: option.isSelected)
                  Spacer()
                  if option.isSelected {
                    Image(systemName: "checkmark.circle")
                      .foregroundColor(.blue)
                  }
                }
                .padding()
                Divider()
              }
              .background(VisualEffecter(.systemThickMaterial))
              .onTapGesture {
                viewModel.select(option.id)
              }
            }
          }
        }
        .frame(maxHeight: 160)

        LinearGradient(colors: [Color.black.opacity(0.3), Color.clear], startPoint: .bottom, endPoint: .top)
          .frame(height: 24)
      }
      .cornerRadius(.extraExtraSmall)

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

struct SpuddleOptionsModifierView_Previews: PreviewProvider {
  static var previews: some View {
    SpuddleOptionsModifierView(viewModel: SpuddleOptionsModifierViewModel(options: [], title: "Test"))
  }
}
