// Copyright © SkeletonView. All rights reserved.

import UIKit

struct SkeletonLayer
{
    private var maskLayer: CALayer
    private weak var holder: UIView?
    private var colors: [UIColor]

    var type: SkeletonType
    {
        return self.maskLayer is CAGradientLayer ? .gradient : .solid
    }

    var contentLayer: CALayer
    {
        return self.maskLayer
    }

    init(type: SkeletonType, colors: [UIColor], skeletonHolder holder: UIView)
    {
        self.holder = holder
        self.colors = colors
        self.maskLayer = type.layer
        self.maskLayer.anchorPoint = .zero
        self.maskLayer.bounds = holder.definedMaxBounds
        self.maskLayer.position = holder.bounds.origin
        self.maskLayer.cornerRadius = CGFloat(holder.skeletonCornerRadius)
        self.addTextLinesIfNeeded()
        self.maskLayer.tint(withColors: colors, traitCollection: holder.traitCollection)
    }

    mutating func update(usingColors colors: [UIColor])
    {
        self.colors = colors
        self.layoutIfNeeded()
        self.maskLayer.tint(withColors: colors, traitCollection: self.holder?.traitCollection)
    }

    func layoutIfNeeded()
    {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer
        {
            CATransaction.commit()
        }

        if let holder = self.holder
        {
            self.maskLayer.bounds = holder.definedMaxBounds
            self.maskLayer.position = holder.bounds.origin
            self.maskLayer.cornerRadius = CGFloat(holder.skeletonCornerRadius)
        }

        let previousLineCount = self.maskLayer.skeletonSublayers.count
        self.updateLinesIfNeeded()
        if previousLineCount != self.maskLayer.skeletonSublayers.count
        {
            self.maskLayer.backgroundColor = nil
            (self.maskLayer as? CAGradientLayer)?.colors = nil
            self.maskLayer.tint(withColors: self.colors, traitCollection: self.holder?.traitCollection)
            if let config = self.holder?._currentSkeletonConfig, config.animated
            {
                self.stopAnimation()
                self.start(config.animation)
            }
        }
    }

    func removeLayer(transition: SkeletonTransitionStyle, completion: (() -> Void)? = nil)
    {
        switch transition
        {
        case .none:
            self.maskLayer.removeFromSuperlayer()
            completion?()
        case .crossDissolve(let duration):
            self.maskLayer.setOpacity(from: 1, to: 0, duration: duration)
            {
                self.maskLayer.removeFromSuperlayer()
                completion?()
            }
        }
    }

    func addTextLinesIfNeeded()
    {
        guard let config = self.textConfig else
        {
            return
        }
        self.maskLayer.addMultilinesLayers(for: config)
        self.maskLayer.updateMultilinesLayers(for: config)
    }

    func updateLinesIfNeeded()
    {
        guard let config = self.textConfig else
        {
            self.maskLayer.skeletonSublayers.forEach
            {
                $0.removeFromSuperlayer()
            }
            return
        }
        self.maskLayer.updateMultilinesLayers(for: config)
    }

    private var textConfig: SkeletonMultilinesLayerConfig?
    {
        guard let textView = self.holderAsTextView else
        {
            return nil
        }
        return SkeletonMultilinesLayerConfig(
            lines: textView.estimatedNumberOfLines,
            lineHeight: textView.estimatedLineHeight,
            type: self.type,
            lastLineFillPercent: textView.lastLineFillingPercent,
            multilineCornerRadius: textView.multilineCornerRadius,
            multilineSpacing: textView.multilineSpacing,
            paddingInsets: textView.paddingInsets,
            alignment: textView.textAlignment,
            isRTL: self.holder?.isRTL ?? false,
            shouldCenterVertically: textView.shouldCenterTextVertically
        )
    }

    var holderAsTextView: SkeletonTextNode?
    {
        guard let textView = self.holder as? SkeletonTextNode else
        {
            return nil
        }
        let lines = textView.estimatedNumberOfLines
        guard lines <= 0 || lines > 1 || !SkeletonAppearance.default.renderSingleLineAsView else
        {
            return nil
        }
        return textView
    }
}

extension SkeletonLayer
{
    func start(_ anim: SkeletonLayerAnimation? = nil, completion: (() -> Void)? = nil)
    {
        let animation = anim ?? self.type.defaultLayerAnimation(isRTL: self.holder?.isRTL ?? false)
        self.contentLayer.playAnimation(animation, key: "skeletonAnimation", completion: completion)
    }

    func stopAnimation()
    {
        self.contentLayer.stopAnimation(forKey: "skeletonAnimation")
    }
}
