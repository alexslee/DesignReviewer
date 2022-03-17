# DesignReviewer

`DesignReviewer` is an in-app alternative to view debugging that you'd normally need to be wired up to
Xcode to perform. 

* When LLDB just won't cooperate: view inspection without needing to wait for Xcode to stop lagging
* When Xcode screeches to a halt: utilize a 3D view hierarchy experience that mimics that of Xcode
* Who needs to recompile?: modify various view/constraint properties, with real-time changes reflected in the preview + back in the app itself
* Sanity check your constraints: quickly view the space between any two views on the screen

## Usage

### Setup
1. Install the package, which can be done via Swift Package Manager. (_If Facebook can claim to only support Cocoapods for React Native that so many devs need, then surely the rest of us mortals can mark our territory with SPM for something only one dev would use?_)

2. Decide how you want to invoke the `DesignReviewer`. This can be via something as straightforward as the action of a `UIButton` press, if you have a fairly simple app or just happen to have a spot where a UIButton could be placed + always accessible. Or, you could go fancier and opt for a shake gesture. Whatever the use case, you should just have to call the following:
```swift
// window being the target window through which the DesignReviewer should parse.
DesignReviewer.start(inAppWindow: window) 
```

### Defining custom attributes to display
You can setup the reviewer to display any custom attributes you wish for a given `DesignReviewable`. However, currently this is limited to KVC-compliant properties. For most Swifty cases, a hopefully helpful suggestion is to append `@objc dynamic` to your property declaration, e.g.:
```swift
  @objc dynamic var dummyString: String {
    return "\(Int.random(in: 1..<5000))"
  }
```
You can then call this function on the `DesignReviewer` to add this attribute to the list of values for display:
```swift
  static func addCustomMutableAttribute<T: DesignReviewable>(_ attribute: DesignReviewCustomMutableAttribute, to reviewable: T.Type)
```
You can add regular property types with the above, but for enum properties you need to handle them a bit differently. They still need
to be `@objc dynamic` unfortunately due to keyPath access requirements. Anyway, you need to call this method to add an enum attribute:
```swift
  static func addCustomEnumAttribute<T: DesignReviewable, EnumDescribing: ReviewableDescribing>(
  _ attribute: DesignReviewCustomEnumAttribute<EnumDescribing>, 
  to reviewable: T.Type)
```

Examples of both of these are provided in the sample project.

---

## TODOs:

- [x] Check tablet appearance + rotation behaviour
- [x] Make color attributes editable
- [x] Add ability for client to provide additional inspectable attributes for any given `DesignReviewable`
  - Note: for now, these custom attributes must be KVC-compliant properties on the `DesignReviewable` types
- [x] Make text attributes editable
- [ ] Refine position of the constraint padding labels
- [ ] Bump min version target up from 12 ("soon :tm:")
- [ ] Properly center the 3D hierarchy rects, rather than just converting the views' rects to the 3D hierarchy coordinate space and using those relative positions
- [ ] All the bugfixes
