/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Animators that run through different facial expressions.
*/

import UIKit

/**

 A face animator manipulates the supplied face view in an entertaining way.

 Each animator can only begin it's work when `start()` is called. And once
 `stop()` is called, the animator must begin cleaning itself up and call the
 `doneCallback` once any latent animations or pauses are complete.

 Once stopped, an animator MUST NOT manipulate the face view.

 The face view ensures that only one animator is active at a time.

 */
protocol FaceAnimator: class {

    /// Starts the animator.
    func start()

    /// Requests to stop the animator. Calls the `doneCallback` when the animator is really done.
    func stop(doneCallback: @escaping () -> ())

}

class NeutralFaceAnimator: FaceAnimator {

    weak var faceView: FaceView?

    init(faceView: FaceView) {
        self.faceView = faceView
    }

    func start() {
        faceView?.image = #imageLiteral(resourceName: "neutral1")
        running = true
        planToBlink()
        planToNod()
    }

    func stop(doneCallback: @escaping () -> ()) {
        running = false
        if nodding {
            whenDoneNodding = doneCallback
        }
        else {
            whenDoneNodding = nil
            doneCallback()
        }
    }

    func planToBlink() {
        let timeUntilBlink = randomInterval(lowerBound: 1, upperBound: 4)
        after(timeUntilBlink) {
            guard self.running, let faceView = self.faceView else { return }
            faceView.image = #imageLiteral(resourceName: "neutral2")
            self.planToUnblink()
        }
    }

    func planToUnblink() {
        let timeUntilUnblink = randomInterval(lowerBound: 0.05, upperBound: 0.15)
        after(timeUntilUnblink) {
            guard self.running, let faceView = self.faceView else { return }
            faceView.image = #imageLiteral(resourceName: "neutral1")
            self.planToBlink()
        }
    }

    func planToNod() {
        let timeUntilNod = randomInterval(lowerBound: 1, upperBound: 6)
        after(timeUntilNod) {
            self.nod()
        }
    }

    func nod() {
        guard self.running, let faceView = self.faceView else { return }

        self.nodding = true
        let nod = CGAffineTransform(rotationAngle: flipACoin() ? 0.1 : -0.1)

        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            faceView.transform = nod
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                faceView.transform = .identity
                }, completion: { _ in
                    self.nodding = false
                    if self.whenDoneNodding != nil {
                        self.cleanup()
                    }
                    else {
                        self.planToNod()
                    }
            })
        }
    }

    func cleanup() {
        running = false
        whenDoneNodding?()
        whenDoneNodding = nil
    }

    private var running = false
    private var nodding = false
    private var whenDoneNodding: (() -> ())?
}

class LaughingFaceAnimator: FaceAnimator {

    weak var faceView: FaceView?

    init(faceView: FaceView) {
        self.faceView = faceView
    }

    func start() {
        running = true

        executeAnimation()
    }

    func stop(doneCallback: @escaping () -> ()) {
        if running {
            whenDoneRunning = doneCallback
        }
        else {
            whenDoneRunning = nil
            running = false
            doneCallback()
        }
    }

    func executeAnimation() {
        guard let faceView = faceView else { cleanup(); return }

        faceView.image = #imageLiteral(resourceName: "laughstart")

        after(0.8) {
            UIView.animate(withDuration: 1, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                faceView.transform = CGAffineTransform(translationX: 0, y: -40)
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                    faceView.transform = CGAffineTransform(translationX: 0, y: 3)
                }) { _ in
                    self.giggleUntilToldToStop()
                }
            }
        }
    }

    var lastTiltAdjustment: CGFloat = 1

    func giggleUntilToldToStop() {
        guard running, let faceView = faceView else { cleanup(); return }

        faceView.image = #imageLiteral(resourceName: "laughtears")

        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            faceView.transform = CGAffineTransform(scaleX: 1, y: 0.95).rotated(by: 0.1 * self.lastTiltAdjustment)
        }) { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                faceView.transform = CGAffineTransform(rotationAngle: 0.1 * -self.lastTiltAdjustment)
            }) { _ in
                if self.whenDoneRunning != nil {
                    self.cleanup()
                }
                else {
                    self.giggleUntilToldToStop()
                }
            }
        }
    }

    func cleanup() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            self.faceView?.transform = CGAffineTransform()
        }) { _ in
            self.running = false
            self.whenDoneRunning?()
            self.whenDoneRunning = nil
        }
    }

    private var running = false
    private var whenDoneRunning: (() -> ())?
}

class ConfusedFaceAnimator: FaceAnimator {

    weak var faceView: FaceView?

    init(faceView: FaceView) {
        self.faceView = faceView
    }

    func start() {
        running = true
        blocking = true
        executeAnimation()
    }

    func stop(doneCallback: @escaping () -> ()) {
        running = false
        if blocking {
            whenDoneRunning = doneCallback
        }
        else {
            whenDoneRunning = nil
            running = false
            doneCallback()
        }
    }

    func executeAnimation() {
        guard running, let faceView = faceView else { cleanup(); return }

        UIView.animate(withDuration: 1, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            faceView.transform = CGAffineTransform(scaleX: 0.90, y: 1)
        }) { _ in
            faceView.image = #imageLiteral(resourceName: "confused")
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                faceView.transform = CGAffineTransform()
            }) { _ in
                self.blocking = false
                if self.whenDoneRunning != nil {
                    self.cleanup()
                }
                else {
                    self.planToNod()
                }
            }
        }
    }

    func planToNod() {
        let timeUntilNod = randomInterval(lowerBound: 2, upperBound: 5)
        after(timeUntilNod) {
            guard self.running, let faceView = self.faceView else { self.cleanup(); return }

            let nod = CGAffineTransform(rotationAngle:flipACoin() ? 0.1 : -0.1)

            self.blocking = true

            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                faceView.transform = nod
            }) { _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                    faceView.transform = .identity
                    }, completion: { _ in
                        self.blocking = false
                        if self.whenDoneRunning != nil {
                            self.cleanup()
                        }
                        else {
                            self.planToNod()
                        }
                })
            }
        }
    }

    func cleanup() {
        running = false
        whenDoneRunning?()
        whenDoneRunning = nil
    }

    private var running = false
    private var blocking = false
    private var whenDoneRunning: (() -> ())?
}

class AnnoyedFaceAnimator: FaceAnimator {

    weak var faceView: FaceView?

    init(faceView: FaceView) {
        self.faceView = faceView
    }

    func start() {
        running = true
        blocking = true
        executeAnimation()
    }

    func stop(doneCallback: @escaping () -> ()) {
        running = false
        if blocking {
            whenDoneRunning = doneCallback
        }
        else {
            whenDoneRunning = nil
            running = false
            doneCallback()
        }
    }

    func executeAnimation() {
        guard running, let faceView = faceView else { cleanup(); return }

        UIView.animate(withDuration: 1, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            faceView.transform = CGAffineTransform(scaleX: 1, y: 0.9)
        }) { _ in
            after(0.5) {
                guard self.running, let faceView = self.faceView else { self.cleanup(); return }

                faceView.image = #imageLiteral(resourceName: "annoyed")
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                    faceView.transform = CGAffineTransform()
                }) { _ in
                    self.blocking = false
                    if self.whenDoneRunning != nil {
                        self.cleanup()
                    }
                    else {
                        self.planToNod()
                    }
                }
            }
        }
    }

    func planToNod() {
        let timeUntilNod = randomInterval(lowerBound: 2, upperBound: 5)
        after(timeUntilNod) {
            guard self.running, let faceView = self.faceView else { self.cleanup(); return }

            let nod = CGAffineTransform(translationX: (flipACoin() ? 6 : -6), y: 0)

            self.blocking = true

            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                faceView.transform = nod
            }) { _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                    faceView.transform = .identity
                    }, completion: { _ in
                        self.blocking = false
                        if self.whenDoneRunning != nil {
                            self.cleanup()
                        }
                        else {
                            self.planToNod()
                        }
                })
            }
        }
    }
    
    func cleanup() {
        running = false
        whenDoneRunning?()
        whenDoneRunning = nil
    }
    
    private var running = false
    private var blocking = false
    private var whenDoneRunning: (() -> ())?
    
}
