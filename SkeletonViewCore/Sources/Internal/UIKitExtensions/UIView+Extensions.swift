//
//  Copyright SkeletonView. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  UIView+Extensions.swift
//
//  Created by Juanpe Catalán on 18/8/21.

import UIKit

extension SkeletonViewExtension where ExtendedType: UIView {

    var treeNode: SkeletonTreeNode<ExtendedType> {
        SkeletonTreeNode<ExtendedType>(self.type)
    }

}

extension UIView {

    /// Flags

    var isSuperviewAStackView: Bool {
        superview is UIStackView
    }

    var isRTL: Bool {
        if #available(iOS 10.0, *), #available(tvOS 10.0, *) {
            return effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            return false
        }
    }

    /// Math

    var definedMaxBounds: CGRect
    {
        return CGRect(origin: .zero, size: self.bounds.size)
    }

    var definedMaxSize: CGSize
    {
        return self.bounds.size
    }

    var definedMaxWidth: CGFloat
    {
        return self.bounds.width
    }

    var definedMaxHeight: CGFloat
    {
        return self.bounds.height
    }

    /// Autolayout

    var widthConstraints: [NSLayoutConstraint] {
        nonContentSizeLayoutConstraints.filter { $0.firstAttribute == NSLayoutConstraint.Attribute.width }
    }

    var heightConstraints: [NSLayoutConstraint] {
        nonContentSizeLayoutConstraints.filter { $0.firstAttribute == NSLayoutConstraint.Attribute.height }
    }

    var skeletonHeightConstraints: [NSLayoutConstraint] {
        nonContentSizeLayoutConstraints.filter {
            $0.firstAttribute == NSLayoutConstraint.Attribute.height
                && $0.identifier?.contains("SkeletonView.Constraint.Height") ?? false
        }
    }

    @discardableResult
    func setHeight(equalToConstant constant: CGFloat) -> NSLayoutConstraint {
        let heightConstraint = heightAnchor.constraint(equalToConstant: constant)
        heightConstraint.identifier = "SkeletonView.Constraint.Height.\(constant)"
        NSLayoutConstraint.activate([heightConstraint])
        return heightConstraint
    }

    var nonContentSizeLayoutConstraints: [NSLayoutConstraint] {
        constraints.filter({ "\(type(of: $0))" != "NSContentSizeLayoutConstraint" })
    }

    /// Animations

    func startSkeletonLayerAnimationBlock(_ anim: SkeletonLayerAnimation? = nil) -> VoidBlock {
        {
            self._isSkeletonAnimated = true
            guard let layer = self._skeletonLayer else { return }
            layer.start(anim) { [weak self] in
                self?._isSkeletonAnimated = false
            }
        }
    }

    var stopSkeletonLayerAnimationBlock: VoidBlock {
        {
            self._isSkeletonAnimated = false
            guard let layer = self._skeletonLayer else { return }
            layer.stopAnimation()
        }
    }

    /// Skeleton Layer

    func addSkeletonLayer(skeletonConfig config: SkeletonConfig)
    {
        guard let skeletonLayer = SkeletonLayerBuilder()
            .setSkeletonType(config.type)
            .addColors(config.colors)
            .setHolder(self)
            .build() else { return }

        self._skeletonLayer = skeletonLayer
        self.layer.insertSkeletonLayer(
            skeletonLayer,
            atIndex: UInt32.max,
            transition: config.transition
        )
        { [weak self] in
            guard let self = self,
                  self._status == .on,
                  self._skeletonLayer?.contentLayer === skeletonLayer.contentLayer else { return }

            // Inserting a layer can cause UIKit to change a text view's content offset.
            (self as? UITextView)?.setContentOffset(.zero, animated: false)
            if config.animated
            {
                self.startSkeletonAnimation(config.animation)
            }
        }
        self._status = .on
    }

    func updateSkeletonLayer(skeletonConfig config: SkeletonConfig)
    {
        guard var skeletonLayer = self._skeletonLayer else { return }
        skeletonLayer.update(usingColors: config.colors)
        self._skeletonLayer = skeletonLayer
        if config.animated
        {
            self.startSkeletonAnimation(config.animation)
        }
        else
        {
            skeletonLayer.stopAnimation()
        }
    }

    func layoutSkeletonLayerIfNeeded()
    {
        guard let skeletonLayer = self._skeletonLayer else { return }
        skeletonLayer.layoutIfNeeded()
    }

    func removeSkeletonLayer()
    {
        guard self.sk.isSkeletonActive,
              let skeletonLayer = self._skeletonLayer,
              let transitionStyle = self._currentSkeletonConfig?.transition else { return }
        skeletonLayer.stopAnimation()
        self._status = .off
        skeletonLayer.removeLayer(transition: transitionStyle)
        { [weak self] in
            guard let self = self,
                  self._skeletonLayer?.contentLayer === skeletonLayer.contentLayer else { return }
            self._skeletonLayer = nil
            self._currentSkeletonConfig = nil
        }
    }
}
