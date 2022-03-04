//
//  DesignReviewHUD.swift
//  
//
//  Created by Alex Lee on 3/4/22.
//

import Foundation
import UIKit

class DesignReviewHUD: UIControl {
  private lazy var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

  private lazy var visualEffectView: UIVisualEffectView = {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.masksToBounds = true

    let imageView = UIImageView(image: UIImage(systemName: "eye")?.withRenderingMode(.alwaysTemplate))
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false

    view.contentView.addSubview(imageView)

    NSLayoutConstraint.activate(imageView.constraints(toView: view.contentView))

    return view
  }()

  override var intrinsicContentSize: CGSize { CGSize(width: 64, height: 64) }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    super.init(frame: .zero)
    backgroundColor = .clear

    addSubview(visualEffectView)

    NSLayoutConstraint.activate(visualEffectView.constraints(toView: self))

    let single = UITapGestureRecognizer(target: self, action: #selector(tapped))
    let double = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    double.numberOfTapsRequired = 2

    single.require(toFail: double)

    addGestureRecognizer(single)
    addGestureRecognizer(double)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    visualEffectView.layer.cornerRadius = bounds.height / 2
  }

  @objc private func tapped() {
    sendActions(for: .touchUpInside)
  }

  @objc private func doubleTapped() {
    sendActions(for: .editingDidEndOnExit)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    setTransform(CGAffineTransform(scaleX: 1.5, y: 1.5))
    feedbackGenerator.prepare()
    feedbackGenerator.impactOccurred()
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    setTransform(.identity)
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    setTransform(.identity)
  }

  private func setTransform(_ transform: CGAffineTransform) {
    let damping: CGFloat = transform == .identity ? 1 : 0.45
    UIView.animate(withDuration: 0.3,
                   delay: 0,
                   usingSpringWithDamping: damping,
                   initialSpringVelocity: 1,
                   options: [.beginFromCurrentState, .allowUserInteraction],
                   animations: {
      self.transform = transform
    }, completion: nil)
  }
}
