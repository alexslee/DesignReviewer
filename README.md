# DesignReviewer

`DesignReviewer` is an in-app alternative to view debugging that you'd normally need to be wired up to
Xcode to perform. 

* When LLDB just won't cooperate: view inspection without needing to wait for Xcode to stop lagging
* When Xcode screeches to a halt: utilize a 3D view hierarchy experience that mimics that of Xcode
* Who needs to recompile?: modify various view/constraint properties, with real-time changes reflected in the preview + back in the app itself
* Sanity check your constraints: quickly view the space between any two views on the screen

## Usage

1. Install the package, which can be done via Swift Package Manager. (_If Facebook can claim to only support Cocoapods for React Native, then surely the rest of us mortals can mark our territory with SPM?_)

2. Decide how you want to invoke the `DesignReviewer`. This can be via something as straightforward as the action of a `UIButton` press, if you have a fairly simple app or just happen to have a spot where a UIButton could be placed + always accessible. Or, you could go fancier and opt for a shake gesture. Whatever the use case, you should just have to call the following:
```swift
// window being the target window through which the DesignReviewer should parse.
DesignReviewer.start(inAppWindow: window) 
```

---

## TODOs:

- [ ] Add ability for client to provide additional inspectable attributes for any given `DesignReviewable`
- [ ] Make text attributes editable
- [ ] Refine position of the constraint padding labels
- [ ] Properly center the 3D hierarchy rects, rather than just converting the views' rects to the 3D hierarchy coordinate space and using those relative positions
- [ ] All the bugfixes
