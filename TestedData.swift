//
//  TestedData.swift
//  DSSBKKChatController
//
//  Created by kkusain on 05/04/16.
//  Copyright © 2016 LLC.86Borders. All rights reserved.
//

import Foundation

//let testedChat1 = Chat(user: User(usernickname: "mattdipasquale", firstName: "Matt", lastName: "Di Pasquale"), lastMessageText: "Thanks for checking out Chats! :-)", lastMessageSentDate: NSDate())

let loadedMessages = [
        [
            Message(incoming: true, text: "I really enjoyed programming with you! :-)", sentDate: NSDate(timeIntervalSinceNow: -60*60*24*2-60*60), deliveryStatus: .New ),
            Message(incoming: false, text: "Thanks! Me too! :-)", sentDate: NSDate(timeIntervalSinceNow: -60*60*24*2), deliveryStatus: .New),
            Message(incoming: false, text: "I really enjoyed programming with you! :-)", sentDate: NSDate(timeIntervalSinceNow: -60*60*24*2-60*60), deliveryStatus: .New ),
            Message(incoming: false, text: "Thanks! Me too! :-)", sentDate: NSDate(timeIntervalSinceNow: -60*60*24*2), deliveryStatus: .New),
            Message(incoming: true, text: "I really enjoyed programming with you! :-)", sentDate: NSDate(timeIntervalSinceNow: -60*60*24*2-60*60), deliveryStatus: .New ),
            Message(incoming: false, text: "Thanks! Me too! :-)", sentDate: NSDate(timeIntervalSinceNow: -60*60*24*2), deliveryStatus: .New),
            Message(incoming: true, text: "I really enjoyed programming with you! :-)", sentDate: NSDate(timeIntervalSinceNow: -60*60*24*2-60*60), deliveryStatus: .New ),
            Message(incoming: false, text: "Thanks! Me too! :-)", sentDate: NSDate(timeIntervalSinceNow: -60*60*24*2), deliveryStatus: .New)
        ],
        [
            Message(incoming: true, text: "Hey, would you like to spend some time together tonight and work on Acani?", sentDate: NSDate(timeIntervalSinceNow: -33), deliveryStatus: .New),
            Message(incoming: false, text: "Sure, I'd love to. How's 6 PM?", sentDate: NSDate(timeIntervalSinceNow: -19), deliveryStatus: .New)
    ],
        [
            Message(incoming: true, text: "Hey, would you like to spend some time together tonight and work on Acani?", sentDate: NSDate(timeIntervalSinceNow: -33), deliveryStatus: .New),
            Message(incoming: false, text: "Sure, I'd love to. How's 6 PM?", sentDate: NSDate(timeIntervalSinceNow: -19), deliveryStatus: .New)
    ],
        [
            Message(incoming: true, text: "Hey, would you like to spend some time together tonight and work on Acani?", sentDate: NSDate(timeIntervalSinceNow: -33), deliveryStatus: .New),
            Message(incoming: false, text: "Sure, I'd love to. How's 6 PM?", sentDate: NSDate(timeIntervalSinceNow: -19), deliveryStatus: .New)
    ],
        [
            Message(incoming: true, text: "Hey, would you like to spend some time together tonight and work on Acani?", sentDate: NSDate(timeIntervalSinceNow: -33), deliveryStatus: .New),
            Message(incoming: false, text: "Sure, I'd love to. How's 6 PM?", sentDate: NSDate(timeIntervalSinceNow: -19), deliveryStatus: .New)
    ],
        [
            Message(incoming: true, text: "Hey, would you like to spend some time together tonight and work on Acani?", sentDate: NSDate(timeIntervalSinceNow: -33), deliveryStatus: .New),
            Message(incoming: false, text: "Sure, I'd love to. How's 6 PM?", sentDate: NSDate(timeIntervalSinceNow: -19), deliveryStatus: .New)
    ],
        [
            Message(incoming: true, text: "Hey, would you like to spend some time together tonight and work on Acani?", sentDate: NSDate(timeIntervalSinceNow: -33), deliveryStatus: .New),
            Message(incoming: false, text: "Sure, I'd love to. How's 6 PM?", sentDate: NSDate(timeIntervalSinceNow: -19), deliveryStatus: .New)
    ],
        [
            Message(incoming: true, text: "Hey, would you like to spend some time together tonight and work on Acani?", sentDate: NSDate(timeIntervalSinceNow: -33), deliveryStatus: .New),
            Message(incoming: false, text: "Sure, I'd love to. How's 6 PM?", sentDate: NSDate(timeIntervalSinceNow: -19), deliveryStatus: .New)
    ]
]

let testedLongTextMessage:String = "Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state. Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state."

let mess1 = Message(incoming: true, text: "message1", sentDate: NSDate.init(timeIntervalSince1970: 1460460023) )
let mess2 = Message(incoming: false, text: "message2", sentDate: NSDate.init(timeIntervalSince1970: 1427717019), deliveryStatus: .Read )
let mess3 = Message(incoming: true, text: "message3", sentDate: NSDate.init(timeIntervalSince1970: 1427716873), deliveryStatus: .Delieveried )
let mess4 = Message(incoming: false, text: "message4", sentDate: NSDate.init(timeIntervalSince1970: 1460460020) )
let mess5 = Message(incoming: true, text: "message5", sentDate: NSDate.init(timeIntervalSince1970: 1427716832), deliveryStatus: .Read )
let mess6 = Message(incoming: true, text: "message6", sentDate: NSDate.init(timeIntervalSince1970: 1427716832), deliveryStatus: .Read )
let mess7 = Message(incoming: true, text: "message7", sentDate: NSDate.init(timeIntervalSince1970: 1427716832), deliveryStatus: .Read )
let mess8 = Message(incoming: true, text: "message8", sentDate: NSDate.init(timeIntervalSince1970: 1427716832), deliveryStatus: .Read )
let mess9 = Message(incoming: true, text: "message9", sentDate: NSDate.init(timeIntervalSince1970: 1427716832), deliveryStatus: .Read )

let arrayMessages = [mess1, mess4, mess2, mess3, mess5, mess6, mess7, mess8, mess9]


let outgoingMes1 = Message(incoming: false, text: "Hey, would you like to spend some time together tonight and work on Acani?", sentDate: NSDate(timeIntervalSinceNow: -33), deliveryStatus: .New)

let outgoingMes2 = Message(incoming: false, text: "Sure, I'd love to. How's 6 PM?", sentDate: NSDate(timeIntervalSinceNow: -19), deliveryStatus: .New)

let outgoingMes3 = Message(incoming: false, text: "Hey, would you like to spend some time together tonight and work on Acani?", sentDate: NSDate(timeIntervalSinceNow: -33), deliveryStatus: .New)

let outgoingMes4 = Message(incoming: false, text: "Sure, I'd love to. How's 6 PM?", sentDate: NSDate(timeIntervalSinceNow: -19), deliveryStatus: .New)

let arrayOutgoingMessages = [outgoingMes1, outgoingMes2, outgoingMes3, outgoingMes4, outgoingMes1, outgoingMes2, outgoingMes3, outgoingMes4]

