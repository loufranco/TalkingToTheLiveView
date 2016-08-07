//#-hidden-code
/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This page introduces the PlaygroundValue enum and lets the learner try sending different enum cases over to Em to see what happens.
*/
//#-end-hidden-code
/*:
 
 When you want to send something over to the always-on live view, you first need to enocde it as a `PlaygroundValue`. This recursive enum defines cases for common primitive data types, just like you would be familiar with in property lists.

 Here's all the cases available to you.

 ```
 public enum PlaygroundValue {
    case array([PlaygroundValue])
    case dictionary([String: PlaygroundValue])
    case string(String)
    case data(Data)
    case date(Date)
    case integer(Int)
    case floatingPoint(Double)
    case boolean(Bool)
 }
 ```
 
 Try running the code below to see what happens when you send different cases over to the live view.

  */

import PlaygroundSupport

let page = PlaygroundPage.current
let proxy = page.liveView as! PlaygroundRemoteLiveViewProxy

let message: PlaygroundValue = .boolean(true)
proxy.send(message)

/*:
 
 You can find out more about how Em responds by viewing the code in `Sources/FaceViewController.swift` on your Mac.

 When you're ready, go to the [next page](@next) to learn how to use `PlaygroundValue` dictionaries to send complex commands to Em.

 */
