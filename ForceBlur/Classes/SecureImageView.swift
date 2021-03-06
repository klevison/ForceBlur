//
//  SecureImageView.swift
//  SecureImage
//
//  Created by Aleksey on 19.07.16.
//  Copyright © 2016 Aleksey Chernish. All rights reserved.
//

import UIKit
import Darwin

/// Displays an image with blur.
open class ForceBlurImageView: UIImageView {

    /// Gets called when pressure changes.
    /// - warning: On devices without 3d touch it's called with 0, 1 values.
    open var pressureChanged: ((CGFloat) -> Void)?

    var recognizer: PressureGestureRecognizer!

    @objc fileprivate var maskLayer: RadialLayer!

    // There should be UIVisualEffectView, but a mask cannot be applied to it on iOS 10: https://forums.developer.apple.com/thread/50854
    fileprivate let blurredImageView = UIImageView()
    let defaultRadius: CGFloat = 30
    open var radius: CGFloat! {
        didSet {
            blurredImageView.image = image?.applyLightEffect(radius: radius ?? defaultRadius)
        }
    }

    open override var image: UIImage? {
        didSet {
            blurredImageView.image = image?.applyLightEffect(radius: radius ?? defaultRadius)
            blurredImageView.frame = bounds
        }
    }

    open override var contentMode: UIViewContentMode {
        didSet {
            blurredImageView.contentMode = contentMode
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupSubviews()
    }

    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setupSubviews()
    }

    public override init(image: UIImage?) {
        super.init(image: image)

        setupSubviews()
    }

    init(image: UIImage?, radius: CGFloat) {
        self.radius = radius
        super.init(image: image)

        setupSubviews()
    }

    fileprivate func setupSubviews() {
        recognizer = PressureGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(recognizer)

        isUserInteractionEnabled = true

        maskLayer = RadialLayer()
        maskLayer.frame = bounds
        blurredImageView.layer.mask = maskLayer

        addSubview(blurredImageView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        blurredImageView.frame = bounds
        maskLayer.frame = bounds
    }
}

// Unblur
private extension ForceBlurImageView {

    @objc func tap(_ sender: PressureGestureRecognizer) {
        let force = sender.force
        pressureChanged?(force)
        print("force: \(sender.force); state: \(sender.state.rawValue)")

        let fromRadius = maskLayer.radius
        stopPerformingTweens()
        maskLayer.origin = recognizer.location(in: self)
        let radius = hypot(frame.width, frame.height) * force
        let duration = TimeInterval(force * force)
        Tween(object: self, key: "maskLayer.radius", from: fromRadius, to: radius, duration: duration, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)).start()
    }
}
