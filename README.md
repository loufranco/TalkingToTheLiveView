# TalkingToTheLiveView: Sending messages to a Swift Playground live view and saving data to its key-value store

NOTE: The [TalkingToTheLiveView sample from WWDC](https://developer.apple.com/library/prerelease/content/samplecode/TalkingToTheLiveView/Introduction/Intro.html) has a couple of Swift compile errors now and doesn't work on the latest iOS 10 Betas. The first commit in this repository is the original source. I will try to keep it up to date as I download iOS 10 Betas.

The LICENSE.txt file is the original one from Apple. All of my commits are in the public domain.

## Change Log

2016-Sep-14: Updated to iOS 10.0.1

2016-Aug-29: Still works with iOS 10 Beta 8 with no further changes

2016-Aug-23: Updated to iOS 10 Beta 7

2016-Aug-07: the only way I can see to get a playground book to the iPad is via AirDrop.  

1. Open Playgrounds on your iPad 
2. AirDrop the .playgroundbook folder to the iPad
3. Follow instructions on the iPad (choose to AirDrop to Playgrounds)

## Original README follows

This Playground Book demonstrates how to talk to the always-on live view process from the main process running the code in the editor.

Examples include:

  - Using the PlaygroundSupport framework
  - Encoding/decoding structs to and from PlaygroundValue cases
  - Talking to the PlaygroundRemoteLiveViewProxy to send messages between the always-on live view process and the main process
  - Using the PlaygroundKeyValueStore to remember things for the next time you open the document

## Requirements

### Build

Xcode 8.0 or later; iOS 10.0 SDK or later

### Runtime

iOS 10.0 or later; Swift Playgrounds on iPad

Copyright (C) 2016 Apple Inc. All rights reserved.
