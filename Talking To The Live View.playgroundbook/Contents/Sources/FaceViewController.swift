/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The UIViewController subclass used as the always-on live view to demonstrate how to send and receive PlaygroundValues with the live view.
*/

import UIKit
import PlaygroundSupport

/**
 
 The view controller that brings all the parts of EM together.

 */
public class FaceViewController: UIViewController, UIGestureRecognizerDelegate {

    var visualEffectView: UIVisualEffectView!
    var faceView: FaceView!
    var responseLabel: UILabel!

    let conversation = Conversation()

    /// The current set of knock, knock joke patterns. They are searched
    /// in order when matching setup/punchlines.
    var patterns: [JokePattern] = [
        JokePattern(setup: "boo", punchline: "cry", response: "That's a classic!", face: .laughing),
        JokePattern(setup: "uint", punchline: "uint", response: "Ummm...really?", face: .annoyed),
    ]

    var tapGesture: UITapGestureRecognizer!
    var highlighGesture: UILongPressGestureRecognizer!

    // MARK: - View Controller Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        let effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
        visualEffectView = UIVisualEffectView(effect: effect)
        view.addSubview(visualEffectView)

        faceView = FaceView(frame: CGRect(x: 0, y: 0, width: 180, height: 200))
        faceView.contentMode = .top
        faceView.translatesAutoresizingMaskIntoConstraints = true
        faceView.layer.masksToBounds = true
        faceView.layer.cornerRadius = 10
        visualEffectView.addSubview(faceView)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        tapGesture.delegate = self
        faceView.isUserInteractionEnabled = true
        faceView.addGestureRecognizer(tapGesture)

        highlighGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.pressedDown))
        highlighGesture.delegate = self
        highlighGesture.minimumPressDuration = 0
        faceView.addGestureRecognizer(highlighGesture)

        responseLabel = UILabel()
        responseLabel.textAlignment = .center
        responseLabel.translatesAutoresizingMaskIntoConstraints = true
        responseLabel.font = UIFont.boldSystemFont(ofSize: 30)
        responseLabel.adjustsFontSizeToFitWidth = true
        responseLabel.numberOfLines = 0
        visualEffectView.contentView.addSubview(responseLabel)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        faceView.moveToEmotionWhenReady(newEmotion: .neutral)

        conversation.transitionObserver = { [weak self] oldState, newState in
            self?.transition(fromState: oldState, toState: newState)
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        visualEffectView.bounds = view.bounds
        visualEffectView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)

        faceView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 85)

        responseLabel.bounds = CGRect(x: 0, y: 0, width: view.bounds.width - 20, height: 200)
        responseLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY + 90)
    }


    // MARK: - Gesture handling

    /// Used to show how many times the face was tapped
    var tapCount = 0

    @objc public func tapped() {
        // If you tap on the face view, we send a string to the other side.
        tapCount+=1
        let message: PlaygroundValue = .string("Hello #\(tapCount)!")
        send(message)
    }

    @objc public func pressedDown() {
        // This recognizer highlights the face while touch is down
        switch highlighGesture.state {
        case .began, .changed:
            faceView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        case .ended, .cancelled, .failed, .possible:
            faceView.backgroundColor = .clear
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == tapGesture && otherGestureRecognizer == highlighGesture || gestureRecognizer == highlighGesture && otherGestureRecognizer == tapGesture
    }


    // MARK: - Methods for processing the conversation

    public func processConversationLine(_ text: String) {
        switch conversation.currentState {
        case .waitingForKnock:
            conversation.transition(toState: .processingKnock(knock: text))
        case .processingKnock:
            // Should synchronously go from waitingForKnock to waitingForReply
            // Handling text at this state shouldn't happen.
            fatalError("Expected to synchronously transition to .waitingForReply")
            break
        case .waitingForReply:
            conversation.transition(toState: .waitingForPunchline(who: text))
        case .waitingForPunchline(let who):
            conversation.transition(toState: .processingPunchline(who: who, punchline: text))
        case .processingPunchline:
            // Should synchronously go from waitingForPunchline to final states.
            // Handling text at this state shouldn't happen.
            fatalError("Expected to synchronously transition to response!")
            break
        case .response:
            conversation.transition(toState: .processingKnock(knock: text))
        }
    }

    /// Immediately updates the visual text under the face.
    /// if `bounce` is true, it gives a slight nod to the face.
    public func reply(_ message: String, bounce: Bool = false) {
        if bounce {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
                self.faceView.transform = CGAffineTransform(translationX: 0, y: 10)
            }) { _ in
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [.beginFromCurrentState], animations: {
                    self.faceView.transform = CGAffineTransform.identity
                }) { _ in
                }
            }
        }
        self.responseLabel.text = message
    }


    // MARK: - Private helper methods

    private func transition(fromState oldState: Conversation.State, toState newState: Conversation.State) {
        switch newState {
        case .waitingForKnock:
            let oldGeneration = conversation.generation
            faceView.moveToEmotionWhenReady(newEmotion: .neutral) { skipped in
                guard oldGeneration == self.conversation.generation && skipped == false else { return }
                self.reply("")
            }
        case .processingKnock(let knock):
            let normalized = normalize(text: knock)
            if normalized.contains("knock knock") {
                if faceView.currentEmotion != .neutral {
                    faceView.moveToEmotionWhenReady(newEmotion: .neutral)
                }

                reply("Who's there?", bounce: true)
                conversation.transition(toState: .waitingForReply)
            }
            else {
                reply("...")
                conversation.transition(toState: .response(message: "I only understand\nknock, knock jokes", face: .confused))
            }
        case .waitingForReply:
            // Noop. The neutral face would have already been established by .waitingForKnock
            break
        case .waitingForPunchline(let who):
            reply("\(who) who?", bounce: true)
        case .processingPunchline(let who, let punchline):
            reply("...")

            let normalizedWho = normalize(text: who)
            let normalizedPunchline = normalize(text: punchline)

            var response: (String, JokePattern.Face)? = nil
            for pattern in patterns {
                if normalizedWho.contains(normalize(text: pattern.setup)) {
                    if normalizedPunchline.contains(normalize(text: pattern.punchline)) {
                        response = (pattern.response, pattern.face)
                        break
                    }
                }
            }

            if let (message, face) = response {
                conversation.transition(toState: .response(message: message, face: face))
            }
            else {
                conversation.transition(toState: .response(message: "I don't get it.", face: .confused))
            }
        case .response(let message, let face):
            showReaction(message: message, face: face)
        }
    }

    private func showReaction(message: String, face: JokePattern.Face) {
        let emotion = jokeFaceToEmotion(face)
        let oldGeneration = conversation.generation

        // Give them impression that the face is thinking
        reply("...")

        faceView.moveToEmotionWhenReady(newEmotion: emotion) { skipped in
            guard oldGeneration == self.conversation.generation && skipped == false else { return }

            after(2) {
                guard oldGeneration == self.conversation.generation else { return }
                self.reply(message)
                self.returnToWaitingToKnockAfter(seconds: 10)
            }
        }
    }

    /// Maps a public joke pattern face request to a face view emotion
    private func jokeFaceToEmotion(_ face: JokePattern.Face) -> FaceView.Emotion {
        switch face {
        case .laughing:
            return .laughing
        case .annoyed:
            return .annoyed
        case .confused:
            return .confused
        }
    }

    private func returnToWaitingToKnockAfter(seconds: TimeInterval) {
        let oldConversationGeneration = conversation.generation

        after(10) { [weak self] in
            // If we've already moved on, then just let the conversation continue
            guard let conversation = self?.conversation, conversation.generation == oldConversationGeneration else { return }

            conversation.transition(toState: .waitingForKnock)
        }
    }

    func addJokePattern(_ pattern: JokePattern) {
        // First check to see if we already have the pattern registered.
        // The setup/punchline pair must be unique.
        // Replace any existing patterns that match the same setup/punchline.

        var indexToRemove: Int? = nil
        for (index, p) in patterns.enumerated() {
            if p.setup == pattern.setup && p.punchline == pattern.punchline {
                indexToRemove = index
                break
            }
        }

        if let index = indexToRemove {
            patterns.remove(at: index)
        }

        patterns.append(pattern)
    }

}

extension FaceViewController: PlaygroundLiveViewMessageHandler {

    public func liveViewMessageConnectionOpened() {
        // We don't need to do anything in particular when the connection opens.
    }

    public func liveViewMessageConnectionClosed() {
        // We don't need to do anything in particular when the connection closes.
    }

    public func receive(_ message: PlaygroundValue) {

        switch message {
        case let .string(text):
            // A text value all by itself is just part of the conversation.
            processConversationLine(text)
        case let .integer(number):
            reply("You sent me the number \(number)!")
        case let .boolean(boolean):
            reply("You sent me the value \(boolean)!")
        case let .floatingPoint(number):
            reply("You sent me the number \(number)!")
        case let .date(date):
            reply("You sent me the date \(date)")
        case .data:
            reply("Hmm. I don't know what to do with data values.")
        case .array:
            reply("Hmm. I don't know what to do with an array.")
        case let .dictionary(dictionary):
            guard case let .string(command)? = dictionary["Command"] else {
                // We received a dictionary without a "Command" key.
                reply("Hmm. I was sent a dictionary, but it was missing a \"Command\".")
                return
            }

            switch command {
            case "Echo":
                if case let .string(message)? = dictionary["Message"] {
                    reply(message, bounce: true)
                }
                else {
                    // We didn't have a message string in the dictionary.
                    reply("Hmm. I was told to \"Echo\" but there was no \"Message\".")
                }
            case "AddJoke":
                if let patternValue = dictionary["Pattern"] {
                    do {
                        let pattern = try JokePattern(playgroundValue: patternValue)
                        addJokePattern(pattern)
                    }
                    catch let error as JokePattern.SerializationError {
                        // If we cannot decode the pattern then someone may have been
                        // experimenting and poking into the key value store.
                        let errorMessage: String
                        switch error {
                        case .valueNotADictionary:
                            errorMessage = "The value of \"Pattern\" was not a dictionary."
                        case .missingSetupString:
                            errorMessage = "Missing the setup string."
                        case .missingPunchlineString:
                            errorMessage = "Missing the punchline string."
                        case .missingResponseString:
                            errorMessage = "Missing the response string."
                        case .missingFaceString:
                            errorMessage = "Missing the face string."
                        case .unknownFaceString(let faceString):
                            errorMessage = "Unknown face string \"\(faceString)\"."
                        }
                        reply("Hmm. I don't know how to interpret the joke pattern you sent. \(errorMessage)")
                    }
                    catch {
                        reply("Hmm. Something went wrong trying to interpret the joke pattern you sent. \(String(reflecting: error))")
                    }
                }
                else {
                    // We didn't have a pattern key, there's nothing to do!
                    reply("Hmm. I was told to \"AddJoke\" but there was no \"Pattern\" to add.")
                }
            default:
                // We received a command we didn't recognize. Let's mention that.
                reply("Hmm. I don't recognize the command \"\(command)\".")
            }
        }
    }
}
