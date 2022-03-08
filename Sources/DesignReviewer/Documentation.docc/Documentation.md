# ``DesignReviewer``

`DesignReviewer` is an in-app alternative to view debugging that you'd normally need to be wired up to
Xcode to perform. 

## Overview

### Setup
1. Install the package, which can be done via Swift Package Manager. (_If Facebook can claim to only support Cocoapods for React Native that so many devs need, then surely the rest of us mortals can mark our territory with SPM for something only one dev would use?_)

2. Decide how you want to invoke the `DesignReviewer`. This can be via something as straightforward as the action of a `UIButton` press, if you have a fairly simple app or just happen to have a spot where a UIButton could be placed + always accessible. Or, you could go fancier and opt for a shake gesture. Whatever the use case, you should just have to call the following:
```swift
// window being the target window through which the DesignReviewer should parse.
DesignReviewer.start(inAppWindow: window) 
```
