//
//  TableDataSource.swift
//  DSSBKKChatController
//
//  Created by kkusain on 05/04/16.
//  Copyright © 2016 LLC.86Borders. All rights reserved.
//

import Foundation
import UIKit

private let numberMsgsOnPage = 5

class TableViewDataSource<Delegate:ChatToolBarProtocol, Data:TrasmitterProviderProtocol>: NSObject, UITableViewDelegate, UITableViewDataSource, ChatProviderUpdateTransmitter {
    
    let tableView: UITableView
    
    init(delegate:Delegate, dataProvider: Data, chat: Chat) {
        
        self.delegate = delegate
        self.chat = chat
        self.tableView = UITableView(frame: CGRectZero, style: .Plain)
        self.dataProvider = dataProvider
        super.init()
        
        let tableView = self.tableView
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.contentInset = UIEdgeInsetsZero
        tableView.keyboardDismissMode = .Interactive
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.initNotifications()
        
        refreshControl.addTarget(self, action: #selector(didRefreshControl), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    deinit {
        if let b = self.blockKeyboardDidShow {
            let center = NSNotificationCenter.defaultCenter()
            center.removeObserver(b)
        }
        if let b = self.blockKeyboardWillShow {
            let center = NSNotificationCenter.defaultCenter()
            center.removeObserver(b)
        }
    }
    
    // MARK: - Public
    
    func tableViewScrollToBottomAnimated(animated: Bool) {
        let lastBottomSection = self.tableView.numberOfSections - 1
        guard lastBottomSection >= 0 else {
            return
        }
        let numberOfRows = self.tableView.numberOfRowsInSection(lastBottomSection)
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows - 1, inSection: lastBottomSection)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: animated)
        }
    }
    
    // MARK: - ChatProviderUpdateTransmitter
    
    func addNewMessage(message: Message) {
        self.chat.allMessages.insert(message, atIndex: 0)
        self.appendNewMessageToTableView()
        if !message.incoming {
            self.dataProvider.commitAction(.SendNewMessage(message.text))
        }
    }
    
    func didFetchNewMessage(dataArray: [AnyObject]) {
        defer {
            refreshControl.endRefreshing()
        }
        guard dataArray.count != 0 else {
            return
        }
        let indexSet = self.chat.addParseMessage(dataArray)
        
        performWithoutAnimation { [unowned self] in
            self.tableView.beginUpdates()
            if self.tableView.numberOfSections > 0 {
                self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .None)
            }
            self.tableView.insertSections(indexSet, withRowAnimation: .None)
            self.tableView.endUpdates()
            return self.toBottomTableView
        }
        
        if !chat.unreadMessageArray.isEmpty {
            self.dataProvider.commitAction(.SendReadStatusForMessagesId(chat.unreadMessageArray) )
            chat.unreadMessageArray.removeAll()
        }
    }
    
    func didGetMessageMetaData(udid: String, status: MessageStatusDelievery?) {
        if let indexPath = chat.updateMessageWith(udid, status: status) {
            performWithoutAnimation { [unowned self] in
                self.tableView.beginUpdates()
                let countOfRowInLastSection = self.tableView.numberOfRowsInSection(indexPath.section) - indexPath.row - 1
                
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: countOfRowInLastSection, inSection: indexPath.section)], withRowAnimation: .None)
                self.tableView.endUpdates()
                return true
            }
        }
    }
    
    // MARK: - private
    private weak var delegate:Delegate!
    private let dataProvider: Data
    private let chat:Chat
    let refreshControl = UIRefreshControl()
    
    var blockKeyboardWillShow: NSObjectProtocol?
    var blockKeyboardDidShow: NSObjectProtocol?
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return chat.loadedMessages.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.loadedMessages[section].count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //        print("cellForRowAtIndexPath section: \(indexPath.section) row: \(indexPath.row)")
        
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier(MessageSentDateTableViewCell.cellIdentifer) as! MessageSentDateTableViewCell!
            if cell == nil {
                cell = MessageSentDateTableViewCell(style: .Default, reuseIdentifier:MessageSentDateTableViewCell.cellIdentifer)
            }
            let message = chat.loadedMessages[indexPath.section][0]
            cell.date = message.sentDate
            cell.setNeedsUpdateConstraints()
            return cell
        } else {
            let cellIdentifier = MessageBubbleTableViewCell<TableViewDataSource>.cellIdentifer
            var cell:MessageBubbleTableViewCell<TableViewDataSource>!
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? MessageBubbleTableViewCell
            if cell == nil {
                cell = MessageBubbleTableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            }
            let numbersOfMessagesInSection = chat.loadedMessages[indexPath.section].count
            let numElement = numbersOfMessagesInSection - indexPath.row
            let message = chat.loadedMessages[indexPath.section][numElement]
            //            print("Cell with messageId", message.id)
            cell.configureWithMessage(message)
            return cell
        }
    }
    
    // MARK: - Ptivate funcs
    private var toBottomTableView: Bool = true
    func  didRefreshControl(isToBottomOfTableView: Bool = false) {
        toBottomTableView = isToBottomOfTableView
        self.dataProvider.commitAction(.FetchHistoryMessages(pageSize: numberMsgsOnPage, messageId: self.chat.firstMessage?.id) )
    }
    
    private func appendNewMessageToTableView() {
        let lastSection = self.tableView.numberOfSections
        let numberOfSectionsMessages = self.chat.loadedMessages.count
        
        //        CATransaction.begin()
        //        CATransaction.setCompletionBlock { [unowned self] in
        //        }
        
        performWithoutAnimation { [unowned self] in
            self.tableView.beginUpdates()
            var inseretedPaths: [NSIndexPath] = []
            if lastSection != numberOfSectionsMessages {
                self.tableView.insertSections(NSIndexSet(index: lastSection), withRowAnimation: .None)
            } else {
                let actualLastSectionInData = lastSection - 1
                let countOfRowInLastSection = self.tableView.numberOfRowsInSection(actualLastSectionInData)
                inseretedPaths = [
                    NSIndexPath(forRow: countOfRowInLastSection, inSection: actualLastSectionInData)
                ]
                self.tableView.insertRowsAtIndexPaths(inseretedPaths, withRowAnimation: .None)
            }
            
            self.tableView.endUpdates()
            return true
        }
        
        
        //        CATransaction.commit()
    }
    
}

extension TableViewDataSource: MessageBubbleTableViewCellProtocol {
    static var fontSizeMessage: CGFloat {
        return 13
    }
}


extension TableViewDataSource {
    
    func performWithoutAnimation(executeBlock:() -> Bool) {
        UIView.performWithoutAnimation { // [unowned self] in
            
            if executeBlock() {
                self.tableViewScrollToBottomAnimated(false)
            }
        }
    }
    
    func initNotifications() {
        blockKeyboardDidShow = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object: nil, queue: nil) { [unowned self] notification in
            self.keyboardDidShow(notification)
        }
        
        blockKeyboardWillShow = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil) { [unowned self] notification in
            self.keyboardWillShow(notification)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        guard frameNew.size.height > Delegate.toolBarMaxHeight  else {
            return
        }
        let insetNewBottom = tableView.convertRect(frameNew, fromView: nil).height
        let insetOld = tableView.contentInset
        let insetChange = insetNewBottom - insetOld.bottom
        let overflow = tableView.contentSize.height - (tableView.frame.height - insetOld.top - insetOld.bottom)
        
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations: (() -> Void) = {
            if !(self.tableView.tracking || self.tableView.decelerating) {
                // Move content with keyboard
                if overflow > 0 {                   // scrollable before
                    self.tableView.contentOffset.y += insetChange
                    if self.tableView.contentOffset.y < -insetOld.top {
                        self.tableView.contentOffset.y = -insetOld.top
                    }
                } else if insetChange > -overflow { // scrollable after
                    self.tableView.contentOffset.y += insetChange + overflow
                }
            }
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16)) // http://stackoverflow.com/a/18873820/242933
            
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion:nil)
        } else {
            animations()
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let insetNewBottom = tableView.convertRect(frameNew, fromView: nil).height
        
        // Inset `tableView` with keyboard
        let contentOffsetY = tableView.contentOffset.y
        tableView.contentInset.bottom = insetNewBottom
        tableView.scrollIndicatorInsets.bottom = insetNewBottom
        // Prevents jump after keyboard dismissal
        if self.tableView.tracking || self.tableView.decelerating {
            tableView.contentOffset.y = contentOffsetY
        }
        guard frameNew.size.height > Delegate.toolBarMaxHeight else {
            return
        }
        self.tableViewScrollToBottomAnimated(true)
    }
}

