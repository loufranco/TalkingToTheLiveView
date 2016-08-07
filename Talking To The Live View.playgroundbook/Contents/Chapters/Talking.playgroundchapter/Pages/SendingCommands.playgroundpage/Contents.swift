//#-hidden-code
/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This page shows how dictionary PlaygroundValues let you build up a complex command that can be interpreted on the other side in the live view code.
*/
//#-end-hidden-code
/*:
 
 By using the `.dictionary` case of `PlaygroundValue`, we can build an ad hoc structure to communicate more complicated data to the always-on live view.
 
 Em knows how to recognize dictionaries that have a "Command" key with a `String` value. The other keys of the dictionary have the parameters of the command.
 
 The easiest one to try is the "Echo" command below. Any `String` value for the "Message" key of the dictionary will be repeated in Em's reply area.
 
  */
import PlaygroundSupport

let page = PlaygroundPage.current
let proxy = page.liveView as! PlaygroundRemoteLiveViewProxy

let command: PlaygroundValue
command = .dictionary([
    "Command": .string("Echo"),
    "Message": .string("Hello!")
    ])
proxy.send(command)

/*:
 
 In the `receive(...)` method on Em's `FaceViewController`, it checks to see if the value it received is a dictionary. Then it checks if there is a "Command" key, and then switches on the value to act on whatever command was given.
 
 In addition to "Echo", Em understands the command "AddJoke". When you're ready, go to the [next page](@next) to learn how to configure new joke patterns with Em.

 */
