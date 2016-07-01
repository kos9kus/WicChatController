//
//  chatToolBar.swift
//  DSSBKKChatController
//
//  Created by kkusain on 06/04/16.
//  Copyright © 2016 LLC.86Borders. All rights reserved.
//

import UIKit
import PureLayout

protocol ChatToolBarProtocol: class {
    static var toolBarMaxHeight: CGFloat { get }
    static var toolBarMessageFontSize: CGFloat { get }
    
    var heightToolBarViewContent: CGFloat { get set }
    func didCreateNewMessage(message: Message)
}

let kChatToolBarSpaceTextViewButton: CGFloat = 3
let kChatToolBarSpaceTextViewInset: CGFloat = 5
let kChatToolBarMinWidthButton: CGFloat = 55
let kChatToolBarMaxWidthButton: CGFloat = 65

private let kChatToolBarFixedToolBarHeight: CGFloat = 44

class ChatToolBar<Delegate where Delegate: ChatToolBarProtocol>: UIToolbar, UITextViewDelegate {
    
    let textView:ChatTextView
    let sendButton:UIButton
    
    init(delegate: Delegate) {
        
        textView = ChatTextView(placeHolder: NSLocalizedString("Message...", comment: "Message..."), font:  UIFont.systemFontOfSize(Delegate.toolBarMessageFontSize))
        sendButton = UIButton(type: .System)
        delegateToolBar = delegate
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 0, height: kChatToolBarFixedToolBarHeight) ) )
        
        //TODO: Look into a prblem with tool bar color
//        super.barTintColor = .whiteColor()

        textView.delegate = self
        self.addSubview(textView)
        
        sendButton.enabled = false
        sendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        sendButton.setTitle(NSLocalizedString("Send", comment: "Chat send button title"), forState: .Normal)
        sendButton.setTitleColor(UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1), forState: .Disabled)
        sendButton.setTitleColor( .lightGrayColor(), forState: .Normal)
        sendButton.addTarget(self, action: #selector(didTapButton), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(sendButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("There is no interface builder")
    }
    
    private var didConstraint = false
    override func updateConstraints() {
        super.updateConstraints()
        if !didConstraint {
            self.textView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: kChatToolBarSpaceTextViewInset, left: kChatToolBarSpaceTextViewInset, bottom: kChatToolBarSpaceTextViewInset, right: 0), excludingEdge: ALEdge.Right)
            
            self.sendButton.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: ALEdge.Left)
            self.textView.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: self.sendButton, withOffset: -kChatToolBarSpaceTextViewButton)
            
            self.sendButton.autoSetDimension(ALDimension.Width, toSize: kChatToolBarMinWidthButton, relation: NSLayoutRelation.GreaterThanOrEqual)
            self.sendButton.autoSetDimension(ALDimension.Width, toSize: kChatToolBarMaxWidthButton, relation: NSLayoutRelation.LessThanOrEqual)
            
            didConstraint = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let height = self.updateTextViewHeight() {
            delegateToolBar.heightToolBarViewContent = height
        }
    }
    
    // MARK: - private
    private weak var delegateToolBar:Delegate!
    
    
    func didTapButton() {
        let message = Message(incoming: false, text: self.textView.text, sentDate: NSDate() )
        delegateToolBar.didCreateNewMessage(message)
        
        self.textView.clearUpTextView()
    }
    
    func textViewDidChange(textView: UITextView) {
        sendButton.enabled = textView.hasText()
        self.setNeedsLayout()
    }
}

extension ChatToolBar {
    
    func updateTextViewHeight() -> CGFloat? {
        let oldHeight = textView.frame.height
        let maxHeight = Delegate.toolBarMaxHeight - 2 * kChatToolBarSpaceTextViewInset
        
        let contentSize = textView.sizeThatFits( CGSize(width: textView.frame.width , height: CGFloat.max) )
        
        var newHeight = min(contentSize.height , maxHeight)
        #if arch(x86_64) || arch(arm64)
            newHeight = ceil(newHeight)
        #else
            newHeight = CGFloat(ceilf(newHeight.native))
        #endif
        if newHeight != oldHeight {
            textView.scrollEnabled = false
            return newHeight + 2 * kChatToolBarSpaceTextViewInset
        } else if newHeight == maxHeight {
            textView.scrollEnabled = true
            textView.scrollToBotom()
        }
        return nil
    }
    
}
