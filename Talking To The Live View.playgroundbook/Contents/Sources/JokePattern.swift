/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Value types for representing knock, knock jokes.
*/

import Foundation
import PlaygroundSupport

/**
 
 Represents a knock, knock joke pattern.

 */
public struct JokePattern {

    public enum Face {
        case laughing
        case confused
        case annoyed
    }

    /// The "setup" of the joke. Expected to be processed using the `normalize(text:)` function.
    public var setup: String

    /// The "punchline" of the joke. Expected to be processed using the `normalize(text:)` function.
    public var punchline: String

    /// The text that shows up underneath the face.
    public var response: String

    /// The expected facial expression when delivering the response.
    public var face: Face

    public init(setup: String, punchline: String, response: String, face: Face) {
        self.setup = setup
        self.punchline = punchline
        self.response = response
        self.face = face
    }

}

/**
 
 This extension provides converstion to and from `PlaygroundValue` so it can be
 used in cross process communication and in the key-value store.

 */
public extension JokePattern {

    /**
     This enum provides specific error information if something goes wrong
     converting from a `PlaygroundValue` into a `JokePattern`.`
     */
    public enum SerializationError: Error {
        case valueNotADictionary
        case missingSetupString
        case missingPunchlineString
        case missingResponseString
        case missingFaceString
        case unknownFaceString(String)
    }

    /// Attempts to initialize a JokePattern with a PlaygroundValue.
    init(playgroundValue: PlaygroundValue) throws {
        guard case let .dictionary(d) = playgroundValue else { throw SerializationError.valueNotADictionary }
        guard case let .string(setup)? = d["Setup"] else { throw SerializationError.missingSetupString }
        guard case let .string(punchline)? = d["Punchline"] else { throw SerializationError.missingPunchlineString }
        guard case let .string(response)? = d["Response"] else { throw SerializationError.missingResponseString }
        guard case let .string(faceString)? = d["Face"] else { throw SerializationError.missingFaceString }

        let face: Face
        switch faceString {
        case "Laughing":
            face = .laughing
        case "Confused":
            face = .confused
        case "Annoyed":
            face = .annoyed
        default:
            throw SerializationError.unknownFaceString(faceString)
        }

        self.setup = setup
        self.punchline = punchline
        self.response = response
        self.face = face
    }

    /// Provides a PlaygroundValue representation of the JokePattern.
    var playgroundValue: PlaygroundValue {
        let faceString: String
        switch face {
        case .laughing:
            faceString = "Laughing"
        case .confused:
            faceString = "Confused"
        case .annoyed:
            faceString = "Annoyed"
        }

        return .dictionary([
            "Setup": .string(setup),
            "Punchline": .string(punchline),
            "Response": .string(response),
            "Face": .string(faceString),
            ])
    }
}
