//
//  ChatMessagesTrasmitter.swift
//  VideoSwitchboard
//
//  Created by kkusain on 20/04/16.
//  Copyright © 2016 KK. All rights reserved.
//

import Foundation

protocol ChatMessagesTrasmitterProtocol: class {
    var source: ChatProviderUpdateTransmitter { get }
    func didCompleteAction(action: ChatTrasmitterAction)
}

protocol ChatProviderUpdateTransmitter: class {
    func didGetMessageMetaData(udid: String, status: MessageStatusDelievery?)
    func didFetchNewMessage(dataArray: [AnyObject] )
    func addNewMessage(message: Message)
}

protocol TrasmitterProviderProtocol {
    func commitAction(action: ChatTrasmitterAction)
}

enum ChatTrasmitterAction {
    case SendNewMessage(String)
    case SendReadStatusForMessagesId([String])
    case DeleteConversation
    case FetchHistoryMessages(pageSize: Int, messageId: String?)
}

private let keyChatMessagesTrasmitterSendMessageParams = "metadata"

class ChatMessagesTrasmitter: NSObject, WICWebServiceDelegate, DSSBWebServiceDelegate, TrasmitterProviderProtocol {
    
    init(delegate: ChatMessagesTrasmitterProtocol, user: UserChat) {
        chatUserObj = user
        super.init()
        self.delegate = delegate
        self.wicService.delegate = self
        self.dssbWebService.delegate = self
        
        self.initNotifications()
    }
    
    deinit {
        if let b = blockNotificationDelievery {
            NSNotificationCenter.defaultCenter().removeObserver(b)
        }
        if let b = blockNotificationNewMessage {
            NSNotificationCenter.defaultCenter().removeObserver(b)
        }
    }
    
    // MARK: Public
    
    func commitAction(action: ChatTrasmitterAction) {
        switch action {
            
        case .SendNewMessage(let message):
            if firstAction == nil && chatUserObj.xmlUserChatMetadata.isEmpty {
                firstAction = action
                self.initiateNewChat()
            } else {
                wicService.sendChatMessageWithAPIKey(chatUserObj.spAPIKey, message: message, toUser: chatUserObj.agentUserName, toUserGroupName: chatUserObj.agentgroupid, fromUserGroupName: chatUserObj.usergroupid, alertMessage: Message.alertMessage, params: [ [keyChatMessagesTrasmitterSendMessageParams: chatUserObj.xmlUserChatMetadata] ])
            }
        case .DeleteConversation:
            wicService.deleteMessagesOfChatHistorAtAPIKey(chatUserObj.spAPIKey, toUser: chatUserObj.agentUserName, fromUser: chatUserObj.usernickname, toUserGroupName: chatUserObj.agentgroupid, fromUserGroupName: chatUserObj.usergroupid)
            break
        case .FetchHistoryMessages(let pageSize, let messageId):
            wicService.fetchMessagesOfChatHistorAtAPIKey(chatUserObj.spAPIKey, pageSize: "\(pageSize)", messageId: messageId, toUser: chatUserObj.agentUserName, fromUser: chatUserObj.usernickname, toUserGroupName: chatUserObj.agentgroupid, fromUserGroupName: chatUserObj.usergroupid)
            break
            
        case .SendReadStatusForMessagesId(let messages):
            wicService.sendReadStatusAtMessages(messages, apiKey: chatUserObj.spAPIKey)
            break
        }
    }
    
    func subscriptPresence(returnBlock: (status: PresenceAgentsStatus) -> () ) {
        wicService.createRequestAtPresence(PresenceSubscribe, presenceIdle: false, listOfUsers: [chatUserObj.agentUserName], withComplectionSuccessBlock: { (presenseStatus) in
            returnBlock(status: presenseStatus)
        }) { (error) in
            print(#function,"+", #line, error.description )
        }
    }
    
    func unsubscribePresence() {
        wicService.createRequestAtPresence(PresenceUnsubscribe, presenceIdle: false, listOfUsers: [chatUserObj.agentUserName], withComplectionSuccessBlock: { (presenseStatus) in
        }) { (error) in
            print(#function,"+", #line, error.description )
        }
    }
    
    // MARK: Private
    let chatUserObj: UserChat
    private weak var delegate: ChatMessagesTrasmitterProtocol!
    private let wicService: WICWebService = WICWebService()
    private let dssbWebService: DSSBWebService = DSSBWebService()
    private var firstAction: ChatTrasmitterAction?
    
    private var blockNotificationDelievery: NSObjectProtocol?
    private var blockNotificationNewMessage: NSObjectProtocol?
    
    private func initiateNewChat() {
        dssbWebService.createWICChatWithUserChat(chatUserObj)
    }
    
    // MARK: DSSBWebServicedelegate
    func dssbCommunication(dssbCommunication: DSSBCommunication!) {
        defer {
            dssbWebService.removeObject(dssbCommunication)
        }
        
        if dssbCommunication.isServiceType(DSSBCreateNewChatInteraction) {
            guard chatUserObj.xmlUserChatMetadata.isEmpty else {
                return
            }
            let xmlStringResponse = dssbCommunication.stringDataResponse
            chatUserObj.xmlUserChatMetadata = xmlStringResponse
            if let action = firstAction {
                self.commitAction(action)
            }
        }
    }
    
    
    func dssbCommunication(dssbCommunication: DSSBCommunication!, didFailWithError error: NSError!) {
        print("\(error.description) + \(#line, "+", #file, "+", #function)")
    }
    
    // MARK: WebServiceDelegate
    func communication(communication: WICCommunication!) {
        defer {
            wicService.removeObject(communication)
        }
        
        if communication.isServiceType(SendChatMessageService) {
            if let udid = communication.theResult.objectForKey("return") as? String {
                self.delegate.source.didGetMessageMetaData(udid, status: nil)
            }
        }
        
        if communication.isServiceType(FetchHistoryChatMessage) {
            self.delegate.didCompleteAction(.FetchHistoryMessages(pageSize: 0, messageId: nil))
            
            self.delegate.source.didFetchNewMessage(communication.arrayResult)
        }
        
        if communication.isServiceType(DeleteHistoryChat) {
            self.delegate.didCompleteAction(.DeleteConversation)
        }
    }
    
    func communication(communication: WICCommunication!, withError error: NSError!) {
        print("\(error.description) + \(#line, "+", #file, "+", #function)")
    }
}

extension ChatMessagesTrasmitter {
    func initNotifications() {
        blockNotificationDelievery = NSNotificationCenter.defaultCenter().addObserverForName(DELIVERY_STATUS_NOFICATION, object: nil, queue: nil) { [unowned self] notification in
            let infoObject = notification.userInfo?[DELIVERY_STATUS_NOFICATION]
            guard let userName = infoObject?["recipient"]??["Agent"]??["name"] as? String where userName == self.chatUserObj.usernickname else {
                return
            }
            
            var statusDelievery: MessageStatusDelievery?
            let udid = infoObject?.objectForKey("messageId") as? String
            if let statusDelieveryString = infoObject?.objectForKey("status") as? String {
                statusDelievery = MessageStatusDelievery(name: statusDelieveryString)
            }
            if let status = statusDelievery, let messageUdid = udid {
                self.delegate.source.didGetMessageMetaData(messageUdid, status: status)
            }
            
        }
        
        blockNotificationNewMessage = NSNotificationCenter.defaultCenter().addObserverForName(CHAT_NEW_MESSAGE_NOFICATION, object: nil, queue: nil, usingBlock: { [unowned self] (notification) in
            let infoObject = notification.userInfo
            //            let sessionId = infoObject!["sessionid"] as! String
            //            let connectionId = infoObject!["connectionid"] as! String
            let agentGroup = infoObject!["agentGroup"] as! String
            let userGroup = infoObject!["userGroup"] as! String
            let agentUserName = infoObject!["fromUser"] as! String
            guard self.chatUserObj.usergroupid == userGroup && self.chatUserObj.agentgroupid == agentGroup else {
                NSNotificationCenter.defaultCenter().postNotificationName(CHAT_MISSED_MESSAGE_NOFICATION, object: nil)
                return
            }
            let textMessage = infoObject!["message"] as! String
            let date = infoObject!["date"] as! NSDate
            let udid = infoObject!["id"] as! String
            let message = Message(incoming: agentUserName != self.chatUserObj.usernickname, text: textMessage, sentDate: date, udid: udid)
            self.delegate.source.addNewMessage(message)
            self.commitAction(.SendReadStatusForMessagesId( [udid] ) )
            })
    }
}
