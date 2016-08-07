//#-hidden-code
/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This first page of the playground book is an introduction. It sets the stage, introduces the story, and provides a quick and simple example with immediate feedback when the learner taps the "Run My Code" button.
*/
//#-end-hidden-code
/*:
 Meet **Em**, a Swift program that loves knock, knock jokes. Em is running in the separate Live View process and will help us demonstrate the **Always-on Live View**.

 Notice how Em's face is blinking, yet the code in the editor isn't running?

 This `say(...)` function sends a message to Em as a line of conversation. We'll unpack how `say(...)` does its magic in a moment.

 Tap *Run My Code* to send the string "Knock, knock" over to the Em in the live view.

 You'll notice Em responds, "Who's there?". Continue the joke by replacing "Knock, knock" with "Boo!" and tap *Run My Code* again.

 Em responds, "Boo! who?". Now, deliver the punchline, "Are you crying?".

 When you're ready, continue to the [next page](@next) to see how this `say(...)` function works.
 */
//#-hidden-code
import PlaygroundSupport

func say(_ message: String) {
    let page = PlaygroundPage.current
    if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
        proxy.send(.string(message))
    }
}
//#-end-hidden-code
say(/*#-editable-code */"<#Knock, knock!#>"/*#-end-editable-code*/)
