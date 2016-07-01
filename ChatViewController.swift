//
//  ViewController.swift
//  DSSBKKChatController
//
//  Created by kkusain on 05/04/16.
//  Copyright © 2016 LLC.86Borders. All rights reserved.
//

import UIKit
import PureLayout

class ChatViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var heightToolBarViewContent: CGFloat = 0 {
        didSet {
            print(self.toolBarHeightConstraint?.constant)
            if let constraint = self.toolBarHeightConstraint {
                constraint.constant = heightToolBarViewContent
                self.dataSource.tableView.contentInset.bottom = heightToolBarViewContent
                self.dataSource.tableViewScrollToBottomAnimated(true)
            }
        }
    }
    
    override var inputAccessoryView: UIView? {
        return self.toolBar
    }
    
    init(user: UserChat) {
        super.init(nibName: nil, bundle: nil)
        self.toolBar = ChatToolBar(delegate: self)
        self.chatTransmitter = ChatMessagesTrasmitter(delegate: self, user: user)
        self.chatNavigationItem = ChatCustomNavigationBar(delegate: self, nameUser: user.fullNameAgent)
        
        SBSharedControllers.sharedMainTabBarPanelController().chatIsEnable = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("There is no interface builder")
    }
    
    deinit {
        SBSharedControllers.sharedMainTabBarPanelController().chatIsEnable = false
        print(#function, "ChatViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .whiteColor()
        self.setupTableView(Chat(user: self.chatTransmitter.chatUserObj) )
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.dataSource.didRefreshControl(true)
        self.chatNavigationItem.setColorForNavigationBar()
    }
    
    private var didSubViews = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didSubViews {
            self.dataSource.tableView.reloadData()
            self.dataSource.tableViewScrollToBottomAnimated(false)
            didSubViews = true
        }
    }
    
    private var didUpdateConstraint = false
    private var toolBarHeightConstraint: NSLayoutConstraint?
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if !didUpdateConstraint {
            for constraint  in self.toolBar.constraints where constraint.firstAttribute == .Height {
                toolBarHeightConstraint = constraint
            }
            didUpdateConstraint = true
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            self.chatNavigationItem.setDefaultBackgroundNavogationBar()
        }
        return true
    }
    
    // MARK: - UIResponder
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: - private
    private typealias Data = ChatMessagesTrasmitter
    private var chatTransmitter: ChatMessagesTrasmitter!
    private var dataSource: TableViewDataSource<ChatViewController, Data>!
    private var toolBar:ChatToolBar<ChatViewController>!
    private var chatNavigationItem: ChatCustomNavigationBar<ChatViewController>!
    
    private func setupTableView(chat: Chat) {
        self.dataSource = TableViewDataSource(delegate: self, dataProvider: chatTransmitter, chat: chat)
        self.view.addSubview(self.dataSource.tableView)
        
        self.dataSource.tableView.autoPinEdgesToSuperviewEdges()
        self.view.setNeedsUpdateConstraints()
    }
}

extension ChatViewController: ChatCustomNavigationBarProtocol {
    func deleteCurrentChat() {
        SBActionController.presentYesNoActionController(self, title: "Erasure", message: "Would you like to remove conversation?") { [unowned self] in
            self.chatTransmitter.commitAction(.DeleteConversation)
        }
    }
    
    func popController() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension ChatViewController: ChatMessagesTrasmitterProtocol {
    
    var source: ChatProviderUpdateTransmitter {
        return self.dataSource
    }
    
    func didCompleteAction(action: ChatTrasmitterAction) {
        switch action {
        case .DeleteConversation:
            self.popController()
        default:
            break
        }
    }
}

extension ChatViewController: ChatToolBarProtocol {
    func didCreateNewMessage(message: Message) {
        dataSource.addNewMessage(message)
    }
    
    static var toolBarMaxHeight: CGFloat {
        return 110
    }
    
    static var toolBarMessageFontSize: CGFloat {
        return 17
    }
}

