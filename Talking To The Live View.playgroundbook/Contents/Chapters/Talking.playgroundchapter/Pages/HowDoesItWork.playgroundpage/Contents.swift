//#-hidden-code
/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This second page of the playground book uses the same code as the introduction page, but it exposes the hidden code and uses markup prose to explain what is going on.
*/
//#-end-hidden-code
/*:
 
 Below is the definition of the `say(...)` function you used on the [previous page](@previous) with some extra comments to explain a bit about what is going on.
 
  */

import PlaygroundSupport

func say(_ message: String) {
    let page = PlaygroundPage.current
    if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
        proxy.send(.string(message))
    }
}

say("<#Knock, knock!#>")

/*:

 Em is using a state machine to track the conversation for the traditional knock-knock joke format: *knock, knock/setup/who's there/punchline*. This state machine advances every time a string is sent over to Em running in the live view.

 Since the always-on live view is running a separate process from the code typed here in the editor, you need to send special messages to the other side to communicate with it.

 The `liveView` property of the current `PlaygroundPage` contains an instance of `PlaygroundRemoteLiveViewProxy` if there is an always-on live view on the other side. This proxy does the work to send `PlaygroundValue`s over to the view controller running in the live view process.
 
 Notice how the `message` is wrapped in the `PlaygroundValue.string` enum case. When you're ready, go to the [next page](@next) to learn more about `PlaygroundValue`.

 And remember, you can find the comprehensive documentation about the Playground Book format and the always-on live view at [developer.apple.com.](http://developer.apple.com)

 */
