/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The UIImageView that displays the face and manages transitioning to different face animators.
*/

import UIKit

/**

 Provides a smart interface over top of UIImageView that will transition
 between face animators in a reliable way.
 
 Use `moveToStateWhenReady` to change the face. You'll get the completion callback
 once the state has changed and the new animator for that state is running.

 */
class FaceView: UIImageView {

    enum Emotion {

        /// Blinking eyes and a pleasant disposition. Just a bit fidgety.
        case neutral

        /// Slow realization that something is funny and then bursts into uncontrollable tears of laughter.
        case laughing

        /// Ponderous look. Not sure how to respond.
        case confused

        /// "Oh....really?"
        case annoyed

    }

    /// The current emotion running in the face view
    private(set) var currentEmotion: Emotion = .neutral

    // If this is ever nil, then you didn't call `start()`
    private var currentFaceAnimator: FaceAnimator?

    /// Stops the face animator after the current animator finishes.
    func stop(completion: (() -> ())? = nil) {
        currentFaceAnimator?.stop(doneCallback: {completion?()})
        currentFaceAnimator = nil
        nextFaceAnimatorRequest?.callbackWhenStarted?(skipped: true)
        nextFaceAnimatorRequest = nil
    }

    /// Request to transition the animator to the new emotion after the current
    /// is completed. `completion` is called back when this happens with `skipped`
    /// set to `true` if another state transition was requested in the meantime and
    /// this emotion was skipped.
    func moveToEmotionWhenReady(newEmotion: Emotion, completion: ((skipped: Bool) -> ())? = nil) {
        if let next = nextFaceAnimatorRequest {
            next.callbackWhenStarted?(skipped: true)
        }

        let animator = makeAnimator(forEmotion: newEmotion)

        nextFaceAnimatorRequest = FaceAnimatorRequest(animator: animator, emotion: newEmotion, callbackWhenStarted: completion)

        let startNext = {
            guard let next = self.nextFaceAnimatorRequest else { return }
            self.currentFaceAnimator = next.animator
            self.currentFaceAnimator?.start()
            next.callbackWhenStarted?(skipped: false)
            self.currentEmotion = next.emotion
        }

        if let currentFaceAnimator = currentFaceAnimator {
            currentFaceAnimator.stop(doneCallback: startNext)
        }
        else {
            startNext()
        }
    }

    /// Returns a new animator for a given facial emotion
    private func makeAnimator(forEmotion emotion: Emotion) -> FaceAnimator {
        switch emotion {
        case .neutral:
            return NeutralFaceAnimator(faceView: self)
        case .laughing:
            return LaughingFaceAnimator(faceView: self)
        case .confused:
            return ConfusedFaceAnimator(faceView: self)
        case .annoyed:
            return AnnoyedFaceAnimator(faceView: self)
        }
    }

    /// Keeps track of the next face animator that should be run once the current
    /// animator has stopped. If another animator is requested then this one is skipped
    /// and `true` is passed to the `skipped` parameter of `callbackWhenStarted`.
    private var nextFaceAnimatorRequest: FaceAnimatorRequest?

    /// An internal structure to keep track of the *next* face animator to run and what to call
    /// when the emotion begins/is skipped.
    struct FaceAnimatorRequest {
        let animator: FaceAnimator
        let emotion: Emotion
        let callbackWhenStarted: ((skipped: Bool) -> ())?
    }

}
