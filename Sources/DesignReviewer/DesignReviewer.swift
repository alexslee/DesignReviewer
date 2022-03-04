//
//  DesignReviewer.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import UIKit

/**
 The app's interface with the `DesignReviewer` tool. Use this to present the reviewer whenever
 you wish (in response to a button press, a gesture, etc.).
 */
public class DesignReviewer {
  private static var coordinator: DesignReviewCoordinator = {
    let viewModel = DesignReviewViewModel()
    return DesignReviewCoordinator(viewModel: viewModel, appWindow: window)
  }()

  private static var window: UIWindow?

  /**
   Spins up the `DesignReviewer`.

   Assuming you've passed in your app/scene window, this should result in the floating eye becoming visible
   in the center of that window's bounds. It can then be dragged out of the way as needed, but while
   it remains visible you are in 'inspect' mode. Simply double tap the floating eye to dismiss and return
   to regular app execution.

   - Parameters:
     - appWindow: The target window through which the `DesignReviewer` should parse.
   */
  public static func start(inAppWindow appWindow: UIWindow?) {
    window = appWindow
    coordinator.start()
  }

  /**
   Ends the current `DesignReviewer` session.

   Note: Unless you want additional control over when to dismiss, you shouldn't have to call this
   method directly. The tool can already be dismissed by double-tapping on the floating eye itself.
   */
  public static func finish() {
    coordinator.finish()
  }
}
