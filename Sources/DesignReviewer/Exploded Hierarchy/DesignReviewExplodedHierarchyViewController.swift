//
//  DesignReviewExplodedHierarchyViewController.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

class DesignReviewExplodedHierarchyViewController: UIViewController {
  private let root: UIView
  private let viewModel: DesignReviewExplodedHierarchyViewModel

  private lazy var container: DesignReviewExplodedHierarchyContainerView = {
    let view = DesignReviewExplodedHierarchyContainerView(reviewable: viewModel.rootReviewable, root: root)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self

    return view
  }()

  private lazy var button: DesignReviewSolidButton = {
    let button = DesignReviewSolidButton(buttonText: "")
    button.addTarget(self, action: #selector(inspectFromHere), for: .touchUpInside)
    button.isHidden = true
    button.translatesAutoresizingMaskIntoConstraints = false

    button.heightAnchor.constraint(equalToConstant: 52).isActive = true

    return button
  }()

  private lazy var effectView: UIVisualEffectView = {
    let isDark = traitCollection.userInterfaceStyle == .dark
    let effect = isDark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
    let view = UIVisualEffectView(effect: effect)
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  private lazy var toolbarEffectContainerView: UIVisualEffectView = {
    let effect = UIBlurEffect(style: .prominent)
    let view = UIVisualEffectView(effect: effect)
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  private lazy var slider: UISlider = {
    let slider = UISlider()
    slider.isContinuous = true
    slider.minimumValue = Float(CGFloat.extraExtraSmall)
    slider.maximumValue = Float(CGFloat.extraExtraLarge)
    slider.value = Float(CGFloat.extraSmall)
    slider.translatesAutoresizingMaskIntoConstraints = false

    slider.addTarget(self, action: #selector(sliderNoSliding), for: .valueChanged)

    return slider
  }()

  private lazy var showNamesToggle: UIView = {
    let switchLabel = UILabel()
    switchLabel.font = .callOut
    switchLabel.numberOfLines = 0
    switchLabel.text = "show names"
    switchLabel.textColor = .monochrome5
    let sonOfASwitch = UISwitch()
    sonOfASwitch.addTarget(self, action: #selector(switchUp), for: .valueChanged)

    let stack = UIStackView(arrangedSubviews: [switchLabel, sonOfASwitch])
    stack.axis = .horizontal
    stack.spacing = .extraExtraSmall
    stack.translatesAutoresizingMaskIntoConstraints = false

    return stack
  }()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(root: UIView, viewModel: DesignReviewExplodedHierarchyViewModel) {
    self.root = root
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .clear

    view.addSubview(effectView)
    view.addSubview(container)
    view.addSubview(toolbarEffectContainerView)
    toolbarEffectContainerView.contentView.addSubview(slider)
    toolbarEffectContainerView.contentView.addSubview(showNamesToggle)
    view.addSubview(button)

    NSLayoutConstraint.activate(effectView.constraints(toView: view))
    NSLayoutConstraint.activate(container.constraints(toView: view))

    NSLayoutConstraint.activate(toolbarEffectContainerView.constraints(toView: view, edges: [.left, .right, .bottom]))

    NSLayoutConstraint.activate([
      slider.leadingAnchor.constraint(equalTo: toolbarEffectContainerView.contentView.leadingAnchor, constant: .medium),
      slider.bottomAnchor.constraint(equalTo: toolbarEffectContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -.large),
      slider.widthAnchor.constraint(equalTo: toolbarEffectContainerView.contentView.widthAnchor, multiplier: 0.5),
      slider.topAnchor.constraint(equalTo: toolbarEffectContainerView.contentView.topAnchor, constant: .extraSmall)
    ])

    NSLayoutConstraint.activate([
      showNamesToggle.trailingAnchor.constraint(equalTo: toolbarEffectContainerView.contentView.trailingAnchor, constant: -.medium),
      showNamesToggle.bottomAnchor.constraint(equalTo: toolbarEffectContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -.large),
      showNamesToggle.widthAnchor.constraint(lessThanOrEqualTo: toolbarEffectContainerView.contentView.widthAnchor, multiplier: 0.5)
    ])

    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: toolbarEffectContainerView.leadingAnchor, constant: .medium),
      button.bottomAnchor.constraint(equalTo: toolbarEffectContainerView.topAnchor, constant: -.small)
    ])
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
      let isDark = traitCollection.userInterfaceStyle == .dark
      effectView.effect = isDark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
    }
  }

  func jumpStart() {
    container.jumpStart()
  }

  func reconstructExplodedHierarchy() {
    container.reconstructExplodedHierarchy()
  }

  @objc private func sliderNoSliding(_ slider: UISlider) {
    container.updateSpacing(slider.value)
  }

  @objc private func inspectFromHere() {
    guard let reviewable = container.primaryView?.baseReviewable else { return }
    viewModel.inspect(reviewable)
  }

  @objc private func switchUp(_ sender: UISwitch) {
    container.toggleNameVisibility(sender.isOn)
  }
}

extension DesignReviewExplodedHierarchyViewController: DesignReviewExplodedHierarchyContainerViewDelegate {
  func containerView(_ container: DesignReviewExplodedHierarchyContainerView,
                     didChangePrimaryView primaryView: DesignReviewExplodedHierarchyView?) {
    button.isHidden = (primaryView == nil)
    guard let reviewable = primaryView?.baseReviewable else { return }
    button.buttonText = "Inspect " + String(describing: reviewable.classForCoder)
  }
}
