// Copyright © SkeletonView. All rights reserved.

import UIKit

extension UIView
{
    func showSkeleton(skeletonConfig config: SkeletonConfig, notifyDelegate: Bool = true)
    {
        self.layoutIfNeeded()
        self._isSkeletonAnimated = config.animated

        if notifyDelegate
        {
            self._flowDelegate = SkeletonFlowHandler()
            self._flowDelegate?.willBeginShowingSkeletons(rootView: self)
        }

        self.recursiveShowSkeleton(skeletonConfig: config, root: self)
    }

    func updateSkeleton(skeletonConfig config: SkeletonConfig, notifyDelegate: Bool = true)
    {
        self._isSkeletonAnimated = config.animated

        if notifyDelegate
        {
            self._flowDelegate?.willBeginUpdatingSkeletons(rootView: self)
        }

        self.recursiveUpdateSkeleton(skeletonConfig: config, root: self)
    }

    func recursiveLayoutSkeletonIfNeeded(root: UIView? = nil)
    {
        self.subviewsSkeletonables.recursiveSearch(leafBlock:
        {
            guard self.isSkeletonable, self.sk.isSkeletonActive else
            {
                return
            }
            self.layoutSkeletonLayerIfNeeded()
            if let config = self._currentSkeletonConfig, config.animated, !self._isSkeletonAnimated
            {
                self.startSkeletonAnimation(config.animation)
            }
        })
        { subview in
            subview.recursiveLayoutSkeletonIfNeeded()
        }

        if let root = root
        {
            self._flowDelegate?.didLayoutSkeletonsIfNeeded(rootView: root)
        }
    }

    func recursiveHideSkeleton(reloadDataAfter reload: Bool, transition: SkeletonTransitionStyle, root: UIView? = nil)
    {
        guard self.sk.isSkeletonActive else
        {
            return
        }
        if self.isHiddenWhenSkeletonIsActive
        {
            self.isHidden = false
        }
        self._currentSkeletonConfig?.transition = transition
        self.removeDummyDataSourceIfNeeded(reloadAfter: reload)
        self.subviewsSkeletonables.recursiveSearch(leafBlock:
        {
            self.tracksSkeletonContent = false
            self.recoverViewState(forced: false)
            self.removeSkeletonLayer()
        })
        { subview in
            subview.recursiveHideSkeleton(reloadDataAfter: reload, transition: transition)
        }

        if let root = root
        {
            self._flowDelegate?.didHideSkeletons(rootView: root)
        }
    }
}

private extension UIView
{
    func showSkeletonIfNotActive(skeletonConfig config: SkeletonConfig)
    {
        guard !self.sk.isSkeletonActive else
        {
            return
        }
        self.saveViewState()
        self.prepareViewForSkeleton()
        self.tracksSkeletonContent = true
        self.addSkeletonLayer(skeletonConfig: config)
    }

    func recursiveShowSkeleton(skeletonConfig config: SkeletonConfig, root: UIView? = nil)
    {
        if self.isHiddenWhenSkeletonIsActive
        {
            self.isHidden = true
        }
        guard self.isSkeletonable, !self.sk.isSkeletonActive else
        {
            return
        }
        self._currentSkeletonConfig = config
        self.swizzleLayoutSubviews()
        self.swizzleTraitCollectionDidChange()
        self.addDummyDataSourceIfNeeded()
        self.subviewsSkeletonables.recursiveSearch(leafBlock:
        {
            self.showSkeletonIfNotActive(skeletonConfig: config)
        })
        { subview in
            subview.recursiveShowSkeleton(skeletonConfig: config)
        }

        if let root = root
        {
            self._flowDelegate?.didShowSkeletons(rootView: root)
        }
    }

    func recursiveUpdateSkeleton(skeletonConfig config: SkeletonConfig, root: UIView? = nil)
    {
        guard self.sk.isSkeletonActive else
        {
            return
        }
        self._currentSkeletonConfig = config
        self.updateDummyDataSourceIfNeeded()
        self.subviewsSkeletonables.recursiveSearch(leafBlock:
        {
            if let skeletonLayer = self._skeletonLayer, skeletonLayer.type != config.type
            {
                self.removeSkeletonLayer()
                self.addSkeletonLayer(skeletonConfig: config)
            }
            else
            {
                self.updateSkeletonLayer(skeletonConfig: config)
            }
        })
        { subview in
            subview.recursiveUpdateSkeleton(skeletonConfig: config)
        }

        if let root = root
        {
            self._flowDelegate?.didUpdateSkeletons(rootView: root)
        }
    }
}
