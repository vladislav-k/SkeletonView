// Copyright © SkeletonView. All rights reserved.

import UIKit

private enum SkeletonViewSwizzling
{
    static let layout: Void =
    {
        swizzle(selector: #selector(setter: UIView.bounds),
                with: #selector(UIView.skeletonSetBounds(_:)),
                inClass: UIView.self,
                usingClass: UIView.self)
        swizzle(selector: #selector(setter: UIView.frame),
                with: #selector(UIView.skeletonSetFrame(_:)),
                inClass: UIView.self,
                usingClass: UIView.self)
        swizzle(selector: #selector(UIView.layoutSubviews),
                with: #selector(UIView.skeletonLayoutSubviews),
                inClass: UIView.self,
                usingClass: UIView.self)
    }()

    static let traits: Void =
    {
        swizzle(selector: #selector(UIView.traitCollectionDidChange(_:)),
                with: #selector(UIView.skeletonTraitCollectionDidChange(_:)),
                inClass: UIView.self,
                usingClass: UIView.self)
    }()

    static let content: Void =
    {
        swizzle(selector: #selector(setter: UIView.backgroundColor),
                with: #selector(UIView.skeletonSetBackgroundColor(_:)),
                inClass: UIView.self,
                usingClass: UIView.self)
        swizzle(selector: #selector(setter: UILabel.text),
                with: #selector(UILabel.skeletonSetText(_:)),
                inClass: UILabel.self,
                usingClass: UILabel.self)
        swizzle(selector: #selector(setter: UILabel.attributedText),
                with: #selector(UILabel.skeletonSetAttributedText(_:)),
                inClass: UILabel.self,
                usingClass: UILabel.self)
        swizzle(selector: #selector(setter: UILabel.textColor),
                with: #selector(UILabel.skeletonSetTextColor(_:)),
                inClass: UILabel.self,
                usingClass: UILabel.self)
        swizzle(selector: #selector(setter: UITextView.text),
                with: #selector(UITextView.skeletonSetText(_:)),
                inClass: UITextView.self,
                usingClass: UITextView.self)
        swizzle(selector: #selector(setter: UITextView.attributedText),
                with: #selector(UITextView.skeletonSetAttributedText(_:)),
                inClass: UITextView.self,
                usingClass: UITextView.self)
        swizzle(selector: #selector(setter: UITextView.textColor),
                with: #selector(UITextView.skeletonSetTextColor(_:)),
                inClass: UITextView.self,
                usingClass: UITextView.self)
        swizzle(selector: #selector(setter: UITextField.text),
                with: #selector(UITextField.skeletonSetText(_:)),
                inClass: UITextField.self,
                usingClass: UITextField.self)
        swizzle(selector: #selector(setter: UITextField.attributedText),
                with: #selector(UITextField.skeletonSetAttributedText(_:)),
                inClass: UITextField.self,
                usingClass: UITextField.self)
        swizzle(selector: #selector(setter: UITextField.textColor),
                with: #selector(UITextField.skeletonSetTextColor(_:)),
                inClass: UITextField.self,
                usingClass: UITextField.self)
        swizzle(selector: #selector(setter: UITextField.placeholder),
                with: #selector(UITextField.skeletonSetPlaceholder(_:)),
                inClass: UITextField.self,
                usingClass: UITextField.self)
        swizzle(selector: #selector(setter: UITextField.attributedPlaceholder),
                with: #selector(UITextField.skeletonSetAttributedPlaceholder(_:)),
                inClass: UITextField.self,
                usingClass: UITextField.self)
        swizzle(selector: #selector(setter: UIImageView.image),
                with: #selector(UIImageView.skeletonSetImage(_:)),
                inClass: UIImageView.self,
                usingClass: UIImageView.self)
        swizzle(selector: #selector(UIButton.setTitle(_:for:)),
                with: #selector(UIButton.skeletonSetTitle(_:for:)),
                inClass: UIButton.self,
                usingClass: UIButton.self)
    }()
}

extension UIView
{
    @objc func skeletonLayoutSubviews()
    {
        self.skeletonLayoutSubviews()
        guard Thread.isMainThread, self.sk.isSkeletonActive else
        {
            return
        }
        self.layoutSkeletonIfNeeded()
    }

    @objc func skeletonTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        self.skeletonTraitCollectionDidChange(previousTraitCollection)
        guard self.isSkeletonable, self.sk.isSkeletonActive,
              let config = self._currentSkeletonConfig else
              {
                  return
              }
        self.updateSkeleton(skeletonConfig: config)
    }

    func swizzleLayoutSubviews()
    {
        _ = SkeletonViewSwizzling.layout
        _ = SkeletonViewSwizzling.content
    }

    func swizzleTraitCollectionDidChange()
    {
        _ = SkeletonViewSwizzling.traits
    }
}

extension UIView
{
    @objc func skeletonSetBackgroundColor(_ value: UIColor?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetBackgroundColor(value)
            return
        }

        self.viewState?.backgroundColor = value
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetBackgroundColor(.clear)
        }
    }
}

extension UILabel
{
    @objc func skeletonSetText(_ value: String?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetText(value)
            return
        }

        self.labelState?.text = value
        self.labelState?.attributedText = nil
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetText(value)
            self.textColor = .clear
        }
    }
}

extension UILabel
{
    @objc func skeletonSetAttributedText(_ value: NSAttributedString?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetAttributedText(value)
            return
        }

        self.labelState?.attributedText = value?.copy() as? NSAttributedString
        self.labelState?.text = nil
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetAttributedText(value)
            self.textColor = .clear
        }
    }
}

extension UILabel
{
    @objc func skeletonSetTextColor(_ value: UIColor?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetTextColor(value)
            return
        }

        self.withoutSkeletonContentTracking
        {
            if let attributedText = self.labelState?.attributedText
            {
                self.attributedText = attributedText
            }
            self.skeletonSetTextColor(value)
            self.labelState?.textColor = self.textColor
            if self.labelState?.attributedText != nil
            {
                self.labelState?.attributedText = self.attributedText?.copy() as? NSAttributedString
            }
            self.skeletonSetTextColor(.clear)
        }
    }
}

extension UITextView
{
    @objc func skeletonSetText(_ value: String?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetText(value)
            return
        }

        self.textState?.text = value
        self.textState?.attributedText = nil
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetText(value)
            self.textColor = .clear
        }
    }
}

extension UITextView
{
    @objc func skeletonSetAttributedText(_ value: NSAttributedString?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetAttributedText(value)
            return
        }

        self.textState?.attributedText = value?.copy() as? NSAttributedString
        self.textState?.text = nil
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetAttributedText(value)
            self.textColor = .clear
        }
    }
}

extension UITextView
{
    @objc func skeletonSetTextColor(_ value: UIColor?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetTextColor(value)
            return
        }

        self.withoutSkeletonContentTracking
        {
            if let attributedText = self.textState?.attributedText
            {
                self.attributedText = attributedText
            }
            self.skeletonSetTextColor(value)
            self.textState?.textColor = self.textColor
            if self.textState?.attributedText != nil
            {
                self.textState?.attributedText = self.attributedText?.copy() as? NSAttributedString
            }
            self.skeletonSetTextColor(.clear)
        }
    }
}

extension UITextField
{
    @objc func skeletonSetText(_ value: String?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetText(value)
            return
        }

        self.textState?.text = value
        self.textState?.attributedText = nil
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetText(value)
            self.textColor = .clear
        }
    }
}

extension UITextField
{
    @objc func skeletonSetAttributedText(_ value: NSAttributedString?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetAttributedText(value)
            return
        }

        self.textState?.attributedText = value?.copy() as? NSAttributedString
        self.textState?.text = nil
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetAttributedText(value)
            self.textColor = .clear
        }
    }
}

extension UITextField
{
    @objc func skeletonSetTextColor(_ value: UIColor?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetTextColor(value)
            return
        }

        self.withoutSkeletonContentTracking
        {
            if let attributedText = self.textState?.attributedText
            {
                self.attributedText = attributedText
            }
            self.skeletonSetTextColor(value)
            self.textState?.textColor = self.textColor
            if self.textState?.attributedText != nil
            {
                self.textState?.attributedText = self.attributedText?.copy() as? NSAttributedString
            }
            self.skeletonSetTextColor(.clear)
        }
    }
}

extension UITextField
{
    @objc func skeletonSetPlaceholder(_ value: String?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetPlaceholder(value)
            return
        }

        self.textState?.placeholder = value
        self.textState?.attributedPlaceholder = nil
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetPlaceholder(nil)
        }
    }
}

extension UITextField
{
    @objc func skeletonSetAttributedPlaceholder(_ value: NSAttributedString?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetAttributedPlaceholder(value)
            return
        }

        self.textState?.attributedPlaceholder = value?.copy() as? NSAttributedString
        self.textState?.placeholder = nil
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetAttributedPlaceholder(nil)
        }
    }
}

extension UIImageView
{
    @objc func skeletonSetImage(_ value: UIImage?)
    {
        guard self.tracksSkeletonContent else
        {
            self.skeletonSetImage(value)
            return
        }

        self.imageState?.image = value
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetImage(nil)
        }
    }
}

extension UIButton
{
    @objc func skeletonSetTitle(_ title: String?, for state: UIControl.State)
    {
        guard self.tracksSkeletonContent, state == .normal else
        {
            self.skeletonSetTitle(title, for: state)
            return
        }

        self.buttonState?.title = title
        self.withoutSkeletonContentTracking
        {
            self.skeletonSetTitle(nil, for: state)
        }
    }
}

extension UIView
{
    @objc func skeletonSetBounds(_ bounds: CGRect)
    {
        self.skeletonSetBounds(bounds)
        guard self._status == .on else
        {
            return
        }
        self.layoutSkeletonLayerIfNeeded()
    }

    @objc func skeletonSetFrame(_ frame: CGRect)
    {
        self.skeletonSetFrame(frame)
        guard self._status == .on else
        {
            return
        }
        self.layoutSkeletonLayerIfNeeded()
    }
}
