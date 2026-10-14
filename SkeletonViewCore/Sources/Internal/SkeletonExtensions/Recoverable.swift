//
//  Recoverable.swift
//  SkeletonView
//
//  Created by Juanpe Catalán on 13/05/2018.
//  Copyright © 2018 SkeletonView. All rights reserved.
//

import UIKit

protocol Recoverable
{
    func saveViewState()
    func recoverViewState(forced: Bool)
}

extension UIView: Recoverable
{
    var viewState: RecoverableViewState?
    {
        get
        {
            return self.ao_get(pkey: &ViewAssociatedKeys.viewState) as? RecoverableViewState
        }
        set
        {
            self.ao_setOptional(newValue, pkey: &ViewAssociatedKeys.viewState)
        }
    }

    @objc func saveViewState()
    {
        self.viewState = RecoverableViewState(view: self)
    }

    @objc func recoverViewState(forced: Bool)
    {
        guard let storedViewState = self.viewState else
        {
            return
        }

        self.startTransition
        { [weak self] in
            guard let self = self else
            {
                return
            }

            self.layer.cornerRadius = storedViewState.cornerRadius
            self.layer.masksToBounds = storedViewState.clipToBounds

            if self.isUserInteractionDisabledWhenSkeletonIsActive
            {
                self.isUserInteractionEnabled = storedViewState.isUserInteractionsEnabled
            }

            self.backgroundColor = storedViewState.backgroundColor
            self.viewState = nil
        }
    }

}

extension UILabel
{
    var labelState: RecoverableLabelState?
    {
        get
        {
            return self.ao_get(pkey: &ViewAssociatedKeys.labelViewState) as? RecoverableLabelState
        }
        set
        {
            self.ao_setOptional(newValue, pkey: &ViewAssociatedKeys.labelViewState)
        }
    }

    override func saveViewState()
    {
        super.saveViewState()
        self.labelState = RecoverableLabelState(view: self)
    }

    override func recoverViewState(forced: Bool)
    {
        super.recoverViewState(forced: forced)
        self.startTransition
        { [weak self] in
            guard let self = self,
                  let storedLabelState = self.labelState else
            {
                return
            }

            NSLayoutConstraint.deactivate(self.skeletonHeightConstraints)
            self.restoreBackupHeightConstraintsIfNeeded()

            self.textColor = storedLabelState.textColor
            if let attributedText = storedLabelState.attributedText
            {
                self.attributedText = attributedText
            }
            else
            {
                self.text = storedLabelState.text
            }
            self.labelState = nil
        }
    }

}

extension UITextView
{
    var textState: RecoverableTextViewState?
    {
        get
        {
            return self.ao_get(pkey: &ViewAssociatedKeys.labelViewState) as? RecoverableTextViewState
        }
        set
        {
            self.ao_setOptional(newValue, pkey: &ViewAssociatedKeys.labelViewState)
        }
    }

    override func saveViewState()
    {
        super.saveViewState()
        self.textState = RecoverableTextViewState(view: self)
    }

    override func recoverViewState(forced: Bool)
    {
        super.recoverViewState(forced: forced)
        self.startTransition
        { [weak self] in
            guard let storedLabelState = self?.textState else
            {
                return
            }

            self?.textColor = storedLabelState.textColor
            if let attributedText = storedLabelState.attributedText
            {
                self?.attributedText = attributedText
            }
            else
            {
                self?.text = storedLabelState.text
            }
            self?.textState = nil
        }
    }

}

extension UITextField
{
    var textState: RecoverableTextFieldState?
    {
        get
        {
            return self.ao_get(pkey: &ViewAssociatedKeys.labelViewState) as? RecoverableTextFieldState
        }
        set
        {
            self.ao_setOptional(newValue, pkey: &ViewAssociatedKeys.labelViewState)
        }
    }

    override func saveViewState()
    {
        super.saveViewState()
        self.textState = RecoverableTextFieldState(view: self)
    }

    override func recoverViewState(forced: Bool)
    {
        super.recoverViewState(forced: forced)
        self.startTransition
        { [weak self] in
            guard let storedLabelState = self?.textState else
            {
                return
            }

            self?.textColor = storedLabelState.textColor
            if let attributedText = storedLabelState.attributedText
            {
                self?.attributedText = attributedText
            }
            else
            {
                self?.text = storedLabelState.text
            }
            self?.textState = nil

            if let placeholder = storedLabelState.attributedPlaceholder
            {
                self?.attributedPlaceholder = placeholder
            }
            else
            {
                self?.placeholder = storedLabelState.placeholder
            }
        }
    }

}

extension UIImageView
{
    var imageState: RecoverableImageViewState?
    {
        get
        {
            return self.ao_get(pkey: &ViewAssociatedKeys.imageViewState) as? RecoverableImageViewState
        }
        set
        {
            self.ao_setOptional(newValue, pkey: &ViewAssociatedKeys.imageViewState)
        }
    }

    override func saveViewState()
    {
        super.saveViewState()
        self.imageState = RecoverableImageViewState(view: self)
    }

    override func recoverViewState(forced: Bool)
    {
        super.recoverViewState(forced: forced)
        self.startTransition
        { [weak self] in
            self?.image = self?.imageState?.image
            self?.imageState = nil
        }
    }

}

extension UIButton
{
    var buttonState: RecoverableButtonViewState?
    {
        get
        {
            return self.ao_get(pkey: &ViewAssociatedKeys.buttonViewState) as? RecoverableButtonViewState
        }
        set
        {
            self.ao_setOptional(newValue, pkey: &ViewAssociatedKeys.buttonViewState)
        }
    }

    override func saveViewState()
    {
        super.saveViewState()
        self.buttonState = RecoverableButtonViewState(view: self)
    }

    override func recoverViewState(forced: Bool)
    {
        super.recoverViewState(forced: forced)
        self.startTransition
        { [weak self] in
            self?.setTitle(self?.buttonState?.title, for: .normal)
            self?.buttonState = nil
        }
    }

}

extension UITableViewHeaderFooterView
{
    var headerFooterState: RecoverableTableViewHeaderFooterViewState?
    {
        get
        {
            return self.ao_get(pkey: &ViewAssociatedKeys.headerFooterViewState) as? RecoverableTableViewHeaderFooterViewState
        }
        set
        {
            self.ao_setOptional(newValue, pkey: &ViewAssociatedKeys.headerFooterViewState)
        }
    }

    override func saveViewState()
    {
        super.saveViewState()
        self.headerFooterState = RecoverableTableViewHeaderFooterViewState(view: self)
    }

    override func recoverViewState(forced: Bool)
    {
        super.recoverViewState(forced: forced)
        self.startTransition
        { [weak self] in
            self?.backgroundView?.backgroundColor = self?.headerFooterState?.backgroundViewColor
        }
    }

}
