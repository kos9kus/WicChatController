//
//  ChatTextView.swift
//  DSSBKKChatController
//
//  Created by kkusain on 07/04/16.
//  Copyright © 2016 LLC.86Borders. All rights reserved.
//

import UIKit

private let kPlaceHolderLabelAlpha: CGFloat = 0.6

class ChatTextView: UITextView {
    
    init(placeHolder: String, font: UIFont ) {
        self.placeHolderLabel = UILabel(frame: CGRectZero)
        
        super.init(frame: CGRectZero, textContainer: nil)
        
        self.textChangingNotifications()
        
        self.backgroundColor = UIColor(white: 250/255, alpha: 1)
        self.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 205/255, alpha:1).CGColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 5
        self.scrollsToTop = false
        self.scrollEnabled = false
        self.font = font
        self.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3)
        self.clipsToBounds = true
        
        self.createPlaceHolderAttributes(placeHolder)
        self.addSubview(self.placeHolderLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        if let b = blockNotification {
            NSNotificationCenter.defaultCenter().removeObserver(b)
        }
    }
    
    private var didFirstLayOut = false
    override func layoutSubviews() {
        super.layoutSubviews()
        self.placeHolderLabel.frame = CGRect(origin: CGPoint(x: 7, y: 0), size: self.frame.size)
    }
    
    // MARK: Ptivate
    private let placeHolderLabel: UILabel
    private var blockNotification: NSObjectProtocol?
    
    private func createPlaceHolderAttributes(text: String) {
        self.placeHolderLabel.text = NSLocalizedString(text, comment: "ChatTextView placeholder")
        self.placeHolderLabel.font = self.font
        self.placeHolderLabel.alpha = kPlaceHolderLabelAlpha
    }
}


extension ChatTextView {
    
    func scrollToBotom() {
        let range = NSMakeRange(text.characters.count - 1, 1);
        scrollRangeToVisible(range);
    }
    
    func clearUpTextView() {
        self.text = ""
        self.delegate?.textViewDidChange?(self)
        self.togglePlaceholder()
    }
    
    private func textChangingNotifications() {
        blockNotification = NSNotificationCenter.defaultCenter().addObserverForName(UITextViewTextDidChangeNotification, object: nil, queue: nil) { [unowned self] (notification: NSNotification) in
            self.togglePlaceholder()
        }
    }
    
    private func togglePlaceholder() {
        if self.hasText()  {
            self.toggleDisplayPlaceholderLabel(animatable: true, setIsVisible: false)
        } else if !self.hasText() {
            self.toggleDisplayPlaceholderLabel(animatable: true, setIsVisible: true)
        }
    }
    
    private func toggleDisplayPlaceholderLabel(animatable animatable: Bool, setIsVisible: Bool) {
        var newAlpha: CGFloat = 0
        if setIsVisible {
            guard self.placeHolderLabel.alpha != kPlaceHolderLabelAlpha else { return }
            newAlpha = kPlaceHolderLabelAlpha
        } else {
            guard self.placeHolderLabel.alpha != 0 else { return }
            newAlpha = 0
        }
        
        
        let animation: (() -> Void) = {
            if setIsVisible {
                self.placeHolderLabel.alpha = newAlpha
                self.placeHolderLabel.transform = CGAffineTransformIdentity
            } else {
                self.placeHolderLabel.alpha = newAlpha
                self.placeHolderLabel.transform = CGAffineTransformMakeTranslation(0.0, -20.0)
            }
        }
        if animatable && setIsVisible {
            UIView.animateWithDuration(0.5, animations: animation)
        } else {
            animation()
        }
    }
}

