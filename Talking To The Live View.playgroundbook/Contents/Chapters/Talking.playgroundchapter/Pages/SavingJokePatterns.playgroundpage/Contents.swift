//#-hidden-code
/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This page demonstrates how to save joke patterns to the key value store by first converting them to PlaygroundValues.
*/
//#-end-hidden-code
/*:
 
 As an added bonus, by building a way to convert your data structures into and out of `PlaygroundValue`, you can store them in the key-value store to load later when this document is reopened.
 
  */
import PlaygroundSupport

let page = PlaygroundPage.current

let joke = JokePattern(setup: "cereal", punchline: "cereal pleasure to meet you", response: "Hahaha!", face: .laughing)
let jokeValue = joke.playgroundValue

let keyValueStore = page.keyValueStore

// This line saves the `PlaygroundValue`
keyValueStore["SavedJoke"] = jokeValue

// And this line pulls it back out
if let value = keyValueStore["SavedJoke"] {
    do {
        // Try to make a joke from the value...
        let joke = try JokePattern(playgroundValue: value)

        // ...and view with inline results.
        joke
    }
    catch {
        // If something goes wrong, take a look at the error with the inline results.
        error
    }
}

/*:

 This initializer on `JokePattern` is the same mechanism that Em uses to decode the `PlaygroundValue` in the live view process. Take a look at `Sources/JokePattern.swift` for how it works and the possible errors that can happen if the `PlaygroundValue` isn't formed as the expected dictionary.
 
 And that is a quick summary of talking to the always-on live view from the code running in the editor!

 */
