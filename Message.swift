import Foundation.NSDate
import UIKit

class Message {
    var id: String?
    let incoming: Bool
    let text: String
    let sentDate: NSDate
    var status: MessageStatusDelievery
    
    init(incoming: Bool, text: String, sentDate: NSDate, deliveryStatus: MessageStatusDelievery = .New, udid: String? = nil) {
        self.incoming = incoming
        self.text = text
        self.sentDate = sentDate
        self.status = deliveryStatus
        self.id = udid
    }
    
}

extension Message {
    
    static var alertMessage: String {
        return NSLocalizedString("Message...", comment: "Message")
    }
    
    static func getDateFromString(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        if let date = dateFormatter.dateFromString(dateString) {
            return date
        }
        return NSDate()
    }
    
    func isEqualDateByTheSameDay(inputMessage: Message) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        return calendar.isDate(self.sentDate, inSameDayAsDate: inputMessage.sentDate)
    }
}

enum MessageStatusDelievery {
    case New
    case Delieveried
    case Read
}

extension MessageStatusDelievery {
    var getProperImage: UIImage? {
        switch self {
        case .New:
            return nil
        case .Delieveried:
            return UIImage(named: "chat-check-ic")
        case .Read:
            return UIImage(named: "chat-check-read")
        }
    }
    
    init(name: String) {
        switch name {
        case "READ":
            self = .Read
        case "DELIVERY":
            self = .Delieveried
        default:
            self = .New
        }
    }
}