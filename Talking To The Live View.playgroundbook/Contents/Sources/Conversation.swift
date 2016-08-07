/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Class to help manage the conversation state for normal knock, knock jokes.
*/

import Foundation

/**

 State machine to keep track of the flow of a conversation.

 Note: this class is **NOT** thread safe.
 
 */
class Conversation {

    enum State {
        // These states are the normal flow for a knock, knock joke
        case waitingForKnock    // Could transition to .doNotUnderstand
        case processingKnock(knock: String)
        case waitingForReply
        case waitingForPunchline(who: String)
        case processingPunchline(who: String, punchline: String)
        case response(message: String, face: JokePattern.Face)
    }

    /// Current state of the conversation
    private(set) var currentState: State = .waitingForKnock {
        didSet { generation += 1}
    }

    /// An always incrementing integer that makes it easy to determine if the conversation has advanced
    /// in the meantime while waiting for an animation to complete. Everytime `currentState` is set
    /// (even if set to the same value), this integer is incremented.
    private(set) var generation: Int = 0

    /// Note, can only transition on the main thread.
    func transition(toState nextState: State) {
        precondition(Thread.isMainThread, "Can only transition state on the main thread.")
        precondition(currentState.canTransition(toState: nextState), "Cannot transition from \(currentState) to \(nextState).")

        let oldState = currentState
        currentState = nextState
        transitionObserver?(oldState: oldState, newState: currentState)
    }

    /// Block that is called whenever the state transitions.
    var transitionObserver: ((oldState: State, newState: State) -> ())? = nil
}

extension Conversation.State {

    /// Used as a precondition to make sure transitions happen between supported states.
    func canTransition(toState nextState: Conversation.State) -> Bool {
        switch (self, nextState) {
        case (.waitingForKnock, .processingKnock),

             (.processingKnock, .waitingForReply),
             (.processingKnock, .response(_, .confused)),

             (.waitingForReply, .waitingForPunchline),

             (.waitingForPunchline, .processingPunchline),

             (.processingPunchline, .response),

             (.response, .waitingForKnock),
             (.response, .processingKnock):

            return true
        default:
            return false
        }
    }
    
}
