//#-hidden-code
/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This page teaches how to send dictionary PlaygroundValues over to the live view as commands to program new Knock, Knock joke patterns.
*/
//#-end-hidden-code
/*:

 You can use these command dictionaries to configure Em to recognize new setup and punchline joke patterns! To make things simple to use, the `JokePattern` struct is used to convert patterns into a `PlaygroundValue` with the `playgroundValue` property.
 
 */
import PlaygroundSupport

let page = PlaygroundPage.current
let proxy = page.liveView as! PlaygroundRemoteLiveViewProxy

/*:

 When you run the code below, you can take a look at the dictionary representation of the joke in the inline results.

 The setup and punchline strings are matched by normalizing the text by stripping all diacritics, lowercasing, and removing all punctuation. Here's what each of the `JokePattern` properties are for:
 
 - `setup`: A keyword or phrase matched to set up the joke
 - `punchline`: A keyword or phrase that is checked for in the response to "Who's there?"
 - `response`: What em should say in return
 - `face`: The animated facial expression, either `.laughing`, `.annoyed`, or `.confused`

 */
let joke = JokePattern(setup: "cereal", punchline: "cereal pleasure to meet you", response: "Hahaha!", face: .laughing)

// Take a look at this value with the inline results to see the dictionary that gets generated.
let jokeValue = joke.playgroundValue

/*:
 
 Once you have `JokePattern` converted into a `PlaygroundValue`, use the "AddJoke" command and the "Pattern" parameter to send it over to Em.
 
 Run the code the first time to configure the joke. Then comment out the line that sends the command and uncomment the line that sends strings to Em and try it out!

 */
let command: PlaygroundValue
command = .dictionary([
    "Command": .string("AddJoke"),
    "Pattern": jokeValue
    ])

proxy.send(command)

// Comment out the line above and uncomment this line below to test out the new joke pattern.
//proxy.send(.string("knock, knock"))

/*:
 
 `JokePattern` is also used internally by Em to represent the setup and punchlines recognized. By creating a value type to describe the jokes we want and building a bridge to convert them into and out of a `PlaygroundValue`, we have a simple way to communicate our data over to the always-on live view process!
 
 When you're ready to continue, go to the [next page](@next) to learn how to save these joke patterns to the key -value store for later use.

 */
