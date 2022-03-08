//
//  ViewController.swift
//  DesignReviewerExample
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit
import DesignReviewer

class ViewController: UIViewController, UIScrollViewDelegate {
  override var canBecomeFirstResponder: Bool { true }

  private lazy var testButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .systemBlue
    button.layer.cornerRadius = 8
    button.tintColor = .white
    button.addTarget(self, action: #selector(tapTapRevenge), for: .touchUpInside)
    button.setTitle("Button button", for: .normal)
    button.setContentCompressionResistancePriority(.required, for: .vertical)

    return button
  }()

  private lazy var testImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(systemName: "hands.clap")?.withRenderingMode(.alwaysTemplate))
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false

    imageView.heightAnchor.constraint(equalToConstant: 88).isActive = true

    return imageView
  }()

  private lazy var testLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 18, weight: .bold)
    label.numberOfLines = 1
    label.text = "do I work"

    label.setContentCompressionResistancePriority(.required, for: .vertical)

    return label
  }()

  private lazy var testLongerLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.text = """
We're no strangers to love
You know the rules and so do I
A full commitment's what I'm thinking of
You wouldn't get this from any other guy
I just wanna tell you how I'm feeling
Gotta make you understand
Never gonna give you up
Never gonna let you down
Never gonna run around and desert you
Never gonna make you cry
Never gonna say goodbye
Never gonna tell a lie and hurt you
We've known each other for so long
Your heart's been aching but you're too shy to say it
Inside we both know what's been going on
We know the game and we're gonna play it
And if you ask me how I'm feeling
Don't tell me you're too blind to see
Never gonna give you up
Never gonna let you down
Never gonna run around and desert you
Never gonna make you cry
Never gonna say goodbye
Never gonna tell a lie and hurt you
Never gonna give you up
Never gonna let you down
Never gonna run around and desert you
Never gonna make you cry
Never gonna say goodbye
Never gonna tell a lie and hurt you
Never gonna give, never gonna give
(Give you up)
We've known each other for so long
Your heart's been aching but you're too shy to say it
Inside we both know what's been going on
We know the game and we're gonna play it
I just wanna tell you how I'm feeling
Gotta make you understand
Never gonna give you up
Never gonna let you down
Never gonna run around and desert you
Never gonna make you cry
Never gonna say goodbye
Never gonna tell a lie and hurt you
Never gonna give you up
Never gonna let you down
Never gonna run around and desert you
Never gonna make you cry
Never gonna say goodbye
Never gonna tell a lie and hurt you
Never gonna give you up
Never gonna let you down
Never gonna run around and desert you
Never gonna make you cry
Never gonna say goodbye
"""

    label.setContentCompressionResistancePriority(.required, for: .vertical)

    return label
  }()

  private lazy var testStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 8

    stack.translatesAutoresizingMaskIntoConstraints = false

    return stack
  }()

  private lazy var testScrollView: UIScrollView = {
    let scroll = UIScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    scroll.maximumZoomScale = 1
    scroll.minimumZoomScale = 1

    scroll.delegate = self

    return scroll
  }()

  private lazy var testNavBarButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "gear"), for: .normal)
    button.addTarget(self, action: #selector(tapTapRevenge), for: .touchUpInside)

    return button
  }()

  @objc private func tapTapRevenge() {
    let alert = UIAlertController(title: "tappity tap", message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "okie dokie artichokey", style: .cancel, handler: nil))
    present(alert, animated: true)
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.x != 0 {
      scrollView.contentOffset.x = 0
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    becomeFirstResponder()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Example Title"
    navigationItem.largeTitleDisplayMode = .always
    navigationController?.navigationBar.prefersLargeTitles = true

    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: testNavBarButton)

    view.backgroundColor = .systemBackground
    testScrollView.backgroundColor = .systemBackground

    view.addSubview(testScrollView)

    testScrollView.addSubview(testStack)
    testStack.addArrangedSubview(testLabel)
    testStack.addArrangedSubview(testImageView)
    testStack.addArrangedSubview(testButton)
    testStack.addArrangedSubview(testLongerLabel)

    NSLayoutConstraint.activate([
      testScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      testScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      testScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      testScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])

    NSLayoutConstraint.activate([
      testStack.leadingAnchor.constraint(equalTo: testScrollView.leadingAnchor, constant: 8),
      testStack.trailingAnchor.constraint(equalTo: testScrollView.trailingAnchor, constant: -8),
      testStack.topAnchor.constraint(equalTo: testScrollView.topAnchor),
      testStack.bottomAnchor.constraint(equalTo: testScrollView.bottomAnchor)
    ])
  }

  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    super.motionEnded(motion, with: event)
    if motion == .motionShake,
      let scene = UIApplication.shared.connectedScenes.first,
      let delegate = scene.delegate as? SceneDelegate {
      DesignReviewer.start(inAppWindow: delegate.window)
    }
  }
}
