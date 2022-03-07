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

  private lazy var button: SolidButton = {
    let button = SolidButton(buttonText: "")
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
    switchLabel.textColor = .black
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
    view.addSubview(slider)
    view.addSubview(showNamesToggle)
    view.addSubview(button)

    NSLayoutConstraint.activate(effectView.constraints(toView: view))
    NSLayoutConstraint.activate(container.constraints(toView: view))

    NSLayoutConstraint.activate([
      slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .medium),
      slider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.large),
      slider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
    ])

    NSLayoutConstraint.activate([
      showNamesToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.medium),
      showNamesToggle.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.large),
      showNamesToggle.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.5)
    ])

    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .medium),
      button.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -.small)
    ])

    title = "Boom"
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if #available(iOS 13, *),
      traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
      let isDark = traitCollection.userInterfaceStyle == .dark
      effectView.effect = isDark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
    }
  }

  func jumpStart() {
    container.jumpStart()
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

class DesignReviewExplodedHierarchyViewModel {
  weak var coordinator: DesignReviewCoordinator?
  let rootReviewable: DesignReviewable

  init(coordinator: DesignReviewCoordinator?, rootReviewable: DesignReviewable) {
    self.coordinator = coordinator
    self.rootReviewable = rootReviewable
  }

  func inspect(_ reviewable: DesignReviewable) {
    coordinator?.presentDesignReview(for: reviewable)
  }
}
