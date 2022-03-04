//
//  DesignReviewExplodedHierarchyContainerView.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

protocol DesignReviewExplodedHierarchyContainerViewDelegate: NSObjectProtocol {
  func containerView(_ container: DesignReviewExplodedHierarchyContainerView,
                     didChangePrimaryView primaryView: DesignReviewExplodedHierarchyView?)
}

class DesignReviewExplodedHierarchyContainerView: UIView {
  // MARK: - Properties
  weak var delegate: DesignReviewExplodedHierarchyContainerViewDelegate?

  private var maxDepth = 0
  private var depthMap = [[DesignReviewExplodedHierarchyView]]()

  var primaryView: DesignReviewExplodedHierarchyView? {
    didSet {
      oldValue?.isCurrentlySelected = false
      primaryView?.isCurrentlySelected = true

      delegate?.containerView(self, didChangePrimaryView: primaryView)
    }
  }

  private let rootView: UIView
  private var rootHierarchyView: DesignReviewExplodedHierarchyView?
  private let rootReviewable: DesignReviewable

  // MARK: Properties for 3D animation values

  private var spacing: CGFloat = .extraSmall
  private var xPos: CGFloat = 0
  private var yPos: CGFloat = 0
  private var zPos: CGFloat = 0
  private var xRotation: CGFloat = 0
  private var yRotation: CGFloat = .pi / 6
  private var zoomScale: CGFloat = 1

  // MARK: - Initializers/setup methods

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(reviewable: DesignReviewable, root: UIView) {
    rootView = root
    rootReviewable = reviewable
    super.init(frame: .zero)

    addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(deadPan)))
    addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(enhance)))
    let movePan = UIPanGestureRecognizer(target: self, action: #selector(iLikeToMoveItMoveIt))
    movePan.minimumNumberOfTouches = 2
    addGestureRecognizer(movePan)
  }

  // Should wait until the parent view controller is done whatever transition (present, push), otherwise
  // animations could clash and the runtime won't like you
  func jumpStart() {
    setupHierarchy()

    // we'll be animating the sublayerTransform property of our layer
    let basicAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.sublayerTransform))

    basicAnimation.duration = 0.3
    basicAnimation.fillMode = .forwards

    /*
     y'all ready for some linear algebra?
     Note: Proofs for how the rotation matrices are derived, along with
     a more organized overview of how these transformations operate, can be found here:
     */
    // TODO: post that writeup somewhere

    /*
     Starting with our identity matrix:
     _              _
    | 1   0   0   0  |
    |                |
    | 0   1   0   0  |
    |                |
    | 0   0   1   0  |
    |                |
    |_0   0   0   1 _|
     You'll notice it's a 4x4. Why? Well, the extra dimension is actually required for translations, and it
     actually does get modified if you need a perspective adjustment too (you'll see that happen below).
     */
    var initialTransformation = CATransform3DIdentity

    /*
     m34 is the z-axis position of the view relative to the viewer - i.e., it controls the z-perspective.
     Think of it almost like moving the vanishing point you would draw on a piece of paper when doing
     perspective drawings.
     _                 _
    | 1   0   0    0    |
    |                   |
    | 0   1   0    0    |
    |                   |
    |             m     |
    | 0   0   1    3,4  |
    |                   |
    |_0   0   0     1  _|
     */
    initialTransformation.m34 = -1 / 2000 * zoomScale

    /*
     Rotate our initialTransformation matrix by xRotation radians, about [1 0 0]
     (i.e. we are performing a rotation about the x-axis only, by the current value of that variable).
     In essence, this is saying 'multiply initialTransformation by our new rotation vector'. How does
     this look in our handy-dandy ASCII art? Well, glad you asked:
                        _                             _
                       | 1       0           0      0  |
                       |                               |
                       | 0     cos(Θ)      sin(Θ)   0  |
     [x   y   z   1] * |                               |
                       | 0     - sin(Θ)    cos(Θ)   0  |
                       |                               |
                       |_0       0           0      1 _|
     Here, Θ is our xRotation, in radians.
     */
    let xRotatedMatrix = CATransform3DRotate(initialTransformation, xRotation, 1, 0, 0)

    /*
     Now, take that rotated matrix and further rotate it by yRotation radians, about [0 1 0]
     (i.e. we are performing a rotation about the y-axis only, by the current value of that variable).
     In essence, this is saying 'multiply xRotatedMatrix by our new rotation vector'. ASCII? Gotchu fam:
                        _                             _
                       |  cos(Θ)   0     - sin(Θ)   0  |
                       |                               |
                       |    0      1       0        0  |
     [x   y   z   1] * |                               |
                       |  sin(Θ)   0     cos(Θ)     0  |
                       |                               |
                       |_   0      0       0        1 _|
     Here, Θ is our yRotation, in radians.
     */
    let finalRotationMatrix = CATransform3DRotate(xRotatedMatrix, yRotation, 0, 1, 0)

    /*
     The last math we'll do is scale our matrix up/down to account for any zoom scale, via a simple
     multiplication (recall that we began our calculations based on an identity matrix):
                        _                 _
                       | s    0    0    0  |
                       |  x                |
                       |                   |
                       | 0    s    0    0  |
     [x   y   z   1] * |       y           |
                       |                   |
                       | 0    0    s    0  |
                       |            z      |
                       |                   |
                       |_0    0    0    1 _|
     Here, 's' refers to the scale at which you zoom each axis (in our case, each axis is scaled equally
     so they would all have the same value of zoomScale).
     */
    let zoomMatrix = CATransform3DMakeScale(zoomScale, zoomScale, zoomScale)
    let endMatrix = CATransform3DConcat(zoomMatrix, finalRotationMatrix)

    /*
     With that calculated, let's configure our animation with from + to values. By the end of the animation,
     the following will have occurred:
                         _                          _
                        | m      m      m      m     |
                        |  1,1    1,2    1,3    1,4  |
                        |                            |
                        | m      m      m      m     |
                        |  2,1    2,2    2,3    2,4  |
     [x   y   z   1 ] * |                            |
                        | m      m      m      m     |
                        |  3,1    3,2    3,3    3,4  |
                        |                            |
                        | m      m      m      m     |
                        |_ 4,1    4,2    4,3    4,4 _|
     Here, [x   y   z   1] represents any given CGPoint of the layer, plus that extra dimension
     mentioned earlier. The coordinate will get normalized such that the extra dimension will always be 1,
     and then the runtime simply drops the extra dimension to obtain the new CGPoint + zPosition.
     */
    basicAnimation.fromValue = CATransform3DIdentity
    basicAnimation.toValue = endMatrix

    /*
     Setting the end matrix before adding the animation, prevents a reset from occuring when complete.
     A reset would otherwise occur because of how CALayers operate - each one has a separate model +
     presentation layer to it. The presentation layer is what gets mutated during a CAAnimation. Once that
     animation ends, the presentation layer gets one last update, changing to whatever the model layer is.
     Hence, to avoid janking back to the initial state after the fact, we set the model layer to the
     end state prior to starting the animation.
     */
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    layer.sublayerTransform = endMatrix
    CATransaction.commit()

    layer.add(basicAnimation, forKey: nil)

    UIView.animate(withDuration: 0.3) {
      self.applySpacingBetweenHierarchyViews()
    }
  }

  private func setupHierarchy() {
    let rootHierarchyView = DesignReviewExplodedHierarchyView(reviewable: rootReviewable, root: rootView)
    var depth = 0

    addViewToExplodedHierarchy(rootHierarchyView, depth: &depth)

    self.rootHierarchyView = rootHierarchyView
    maxDepth = depth

    if rootReviewable.subReviewables.isEmpty == false {
      rootHierarchyView.layer.contents = nil
    }
  }
}

// MARK: - Gesture recognizers

extension DesignReviewExplodedHierarchyContainerView {
  @objc private func deadPan(_ sender: UIPanGestureRecognizer) {
    guard sender.state == .changed else { return }

    let translation = sender.translation(in: self)
    xRotation -= .pi * (translation.y / 100)
    yRotation += .pi * (translation.x / 100)

    if yRotation > .pi * 2 {
      yRotation -= .pi * 2
    } else if yRotation < -(.pi * 2) {
      yRotation += .pi * 2
    }

    updateHierarchy()

    // reset translation, so that any subsequent rotation remains incremental
    sender.setTranslation(.zero, in: self)
  }

  @objc private func enhance(_ sender: UIPinchGestureRecognizer) {
    if sender.state == .began {
      sender.scale = zoomScale
      return
    }

    if sender.state == .changed {
      zoomScale = sender.scale
      updateHierarchy()
    }
  }

  @objc private func iLikeToMoveItMoveIt(_ sender: UIPanGestureRecognizer) {
    guard sender.state == .changed else { return }

    let translation = sender.translation(in: self)
    xPos += translation.x
    yPos += translation.y

    updateHierarchy()

    // reset translation, so that any subsequent translation remains incremental
    sender.setTranslation(.zero, in: self)
  }
}

// MARK: - Helpers

extension DesignReviewExplodedHierarchyContainerView {
  /// Recursively adds views to the exploded hierarchy.
  private func addViewToExplodedHierarchy(_ newView: DesignReviewExplodedHierarchyView, depth: inout Int) {
    addSubview(newView)
    newView.container = self

    depthMap.count == depth ? depthMap.append([newView]) : depthMap[depth].append(newView)

    var subviewRects = [CGRect]()
    var maxDepth = depth

    for child in newView.children {
      child.depthInHierarchy = newView.depthInHierarchy + 1

      var childDepth = subviewRects.contains(where: {
        $0.intersects(child.convertedFrame)
      }) ? maxDepth + 1 : depth + 1

      // recursive call
      addViewToExplodedHierarchy(child, depth: &childDepth)

      subviewRects.append(child.convertedFrame)
      maxDepth = max(maxDepth, childDepth)
    }

    depth = maxDepth
  }

  /**
   As the name suggests, applies the current spacing value as an offset to the z-axis position of each
   hierarchy view.
  */
  private func applySpacingBetweenHierarchyViews() {
    // add z-axis spacing between each layer of the hierarchy
    for subview in subviews {
      guard let hierarchyView = subview as? DesignReviewExplodedHierarchyView else { continue }

      let spacingFactor = spacing * CGFloat(hierarchyView.depthInHierarchy)
      hierarchyView.layer.transform = CATransform3DMakeTranslation(0, 0, zPos + spacingFactor)
    }
  }

  func updateSpacing(_ newValue: Float) {
    spacing = CGFloat(newValue)
    applySpacingBetweenHierarchyViews()
  }

  /// Updates the visibility of the class names of all the hierarchy views.
  func toggleNameVisibility(_ shouldShow: Bool) {
    for subview in subviews {
      guard let hierarchyView = subview as? DesignReviewExplodedHierarchyView else { continue }

      hierarchyView.toggleNameVisibility(shouldShow)
    }
  }

  /**
   Updates the transform applied to this container view. See the in-line comments of the `jumpStart`
   method for a walk-through of the calculations.
   */
  private func updateHierarchy() {
    var transformationMatrix = CATransform3DIdentity
    transformationMatrix.m34 = -1 / 2000 * zoomScale
    let xRotatedMatrix = CATransform3DRotate(transformationMatrix, xRotation, 1, 0, 0)
    let finalRotationMatrix = CATransform3DRotate(xRotatedMatrix, yRotation, 0, 1, 0)

    let newAnchor = CGPoint(x: 0.5 - (xPos / bounds.width), y: 0.5 - (yPos / bounds.height))
    layer.anchorPoint = newAnchor

    let zoomMatrix = CATransform3DMakeScale(zoomScale, zoomScale, zoomScale)
    let translationMatrix = CATransform3DMakeTranslation(xPos, yPos, 0)

    let firstConcatenation = CATransform3DConcat(zoomMatrix, finalRotationMatrix)
    let finalConcatentation = CATransform3DConcat(firstConcatenation, translationMatrix)

    layer.sublayerTransform = finalConcatentation

    applySpacingBetweenHierarchyViews()
  }
}
