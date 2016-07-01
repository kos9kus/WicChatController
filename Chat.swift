import Foundation.NSDate

class Chat {
    let user: UserChat
    
    //    var lastMessageText: String
    //    var lastMessageSentDate: NSDate
    //    var lastMessageSentDateString: String {
    //        return formatDate(lastMessageSentDate)
    //    }
    
    var loadedMessages = [ [Message] ]()
    
    var allMessages = [Message]() {
        didSet {
            loadedMessages = getNewArrayOfLoadedMessages()
        }
    }
    
    var firstMessage: Message? {
        return loadedMessages.count > 0 ? loadedMessages[0].last : nil
    }
    
    var unreadMessageArray: [String] = []
//    var hasUnloadedMessages = false
//    var draft = ""
    
    init(user: UserChat) {
        self.user = user
    }
    
    deinit {
        print(#function, "Chat")
    }
    
    // MARK: - Public
    
    func updateMessageWith(udid: String, status: MessageStatusDelievery?) -> NSIndexPath? {
        for (indexItemArray, itemArr) in loadedMessages.enumerate() {
            var indexNillItem: Int?
            for (index, item) in itemArr.enumerate() where !item.incoming {
                if item.id == nil {
                    indexNillItem = index
                    break
                } else if let status = status where item.id == udid && item.status != .Read {
                    item.status = status
                    return NSIndexPath(forRow: index, inSection: indexItemArray)
                } else if status == nil && item.id == udid {
                    return nil
                }
            }
            
            if let index = indexNillItem {
                itemArr[index].id = udid
                if let status = status {
                    itemArr[index].status = status
                    return NSIndexPath(forRow: index, inSection: indexItemArray)
                }
                return nil
            }
        }
        return nil
    }
    
    func addParseMessage(messages: [AnyObject]) -> NSIndexSet {
        let arrayTypeMessages = messages.map { (message) -> Message in
            let messageId = message.objectForKey("messageId") as! String
            let userNameFrom = message.objectForKey("fromUser") as! String
            let messageBody = message.objectForKey("message") as! String
            let statusString = message.objectForKey("status") as! String
            let date = NSDate.getDateFromStringTimestamp(message.objectForKey("date") as! String)
            let message = Message(incoming: user.usernickname != userNameFrom, text: messageBody, sentDate: date, deliveryStatus: MessageStatusDelievery(name: statusString), udid: messageId)
            self.addUnreadMessageId(message)
            
            return message
        }
        
        let numberOfSectionsPriorToUpdate = self.loadedMessages.count
        self.allMessages = self.allMessages + arrayTypeMessages
        let numberOfSectionsAfterUpdate = self.loadedMessages.count
        
        let lengthRange = numberOfSectionsPriorToUpdate > 0 ? (numberOfSectionsAfterUpdate - numberOfSectionsPriorToUpdate) + 1 : numberOfSectionsAfterUpdate
        let range = NSRange(location: 0, length: lengthRange )
        return NSIndexSet(indexesInRange: range)
    }
    
    // MARK: - Private
    private func addUnreadMessageId(message: Message) {
        if let id = message.id where message.incoming && message.status != .Read {
            self.unreadMessageArray.append(id)
        }
    }
    
    private func getNewArrayOfLoadedMessages() -> [ [Message] ] {
        var newSortedMessage = [ [Message] ]()
        _ = allMessages.map { (message) ->  [Message]  in
            return allMessages.filter({ (filterMessage) -> Bool in
                return  filterMessage.isEqualDateByTheSameDay(message)
            }) }.map({  (messageArr) in
                if !newSortedMessage.contains({ (arr: [Message]) -> Bool in
                    return  arr.first! === messageArr.first!
                }) {
                    newSortedMessage.insert(messageArr, atIndex: 0)
                }
                if newSortedMessage.isEmpty {
                    newSortedMessage.append(messageArr)
                }
            })
        return newSortedMessage
    }
}

