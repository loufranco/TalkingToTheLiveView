# TalkingToTheLiveView: Sending messages to a Swift Playground live view and saving data to its key-value store

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
