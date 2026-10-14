//
//  RecoverableViewState.swift
//  SkeletonView
//
//  Created by Juanpe Catalán on 13/05/2018.
//  Copyright © 2018 SkeletonView. All rights reserved.
//

import UIKit

struct RecoverableViewState
{
    var backgroundColor: UIColor?
    var cornerRadius: CGFloat
    var clipToBounds: Bool
    var isUserInteractionsEnabled: Bool

    init(view: UIView)
    {
        self.backgroundColor = view.backgroundColor
        self.clipToBounds = view.layer.masksToBounds
        self.cornerRadius = view.layer.cornerRadius
        self.isUserInteractionsEnabled = view.isUserInteractionEnabled
    }

}

struct RecoverableLabelState
{
    var attributedText: NSAttributedString?
    var text: String? // we mess with `text` if the label is within a `UIStackView`
    var textColor: UIColor?

    init(view: UILabel)
    {
        if let attributedText = view.attributedText
        {
            self.attributedText = attributedText.copy() as? NSAttributedString
        }
        else
        {
            self.text = view.text
        }
        self.textColor = view.textColor
    }
}

struct RecoverableTextViewState
{
    var text: String?
    var attributedText: NSAttributedString?
    var textColor: UIColor?

    init(view: UITextView)
    {
        self.text = view.text
        self.attributedText = view.attributedText?.copy() as? NSAttributedString
        self.textColor = view.textColor
    }
}

struct RecoverableTextFieldState
{
    var text: String?
    var attributedText: NSAttributedString?
    var textColor: UIColor?
    var placeholder: String?
    var attributedPlaceholder: NSAttributedString?

    init(view: UITextField)
    {
        self.text = view.text
        self.attributedText = view.attributedText?.copy() as? NSAttributedString
        self.textColor = view.textColor
        self.placeholder = view.placeholder
        self.attributedPlaceholder = view.attributedPlaceholder?.copy() as? NSAttributedString
    }
}

struct RecoverableImageViewState
{
    var image: UIImage?

    init(view: UIImageView)
    {
        self.image = view.image
    }
}

struct RecoverableButtonViewState
{
    var title: String?

    init(view: UIButton)
    {
        self.title = view.titleLabel?.text
    }
}

struct RecoverableTableViewHeaderFooterViewState
{
    var backgroundViewColor: UIColor?

    init(view: UITableViewHeaderFooterView)
    {
        self.backgroundViewColor = view.backgroundView?.backgroundColor
    }
}
