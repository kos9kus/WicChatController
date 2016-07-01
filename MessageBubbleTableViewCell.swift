import UIKit
import PureLayout

protocol MessageBubbleTableViewCellProtocol {
    static var fontSizeMessage: CGFloat { get }
}

let incomingTag = 100, outgoingTag = 101
let bubbleTag = 8

class MessageBubbleTableViewCell<Delegate: MessageBubbleTableViewCellProtocol>: UITableViewCell {
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        bubbleImageView = UIImageView(image: self.bubbleImage.incoming, highlightedImage: self.bubbleImage.incomingHighlighed)
        bubbleImageView.tag = bubbleTag
        bubbleImageView.userInteractionEnabled = true // #CopyMesage
        
        messageLabel = UILabel(frame: CGRectZero)
        messageLabel.font = UIFont.systemFontOfSize(Delegate.fontSizeMessage)
        messageLabel.numberOfLines = 0
        messageLabel.userInteractionEnabled = false   // #CopyMessage
        
        delieveredTickImageView = UIImageView(frame: CGRectZero)
        
        dateMessageLabel = UILabel(frame: CGRectZero)
        dateMessageLabel.backgroundColor = .whiteColor()
        dateMessageLabel.font = UIFont(name: "Helvetica", size: 11)
        
        
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        tag = incomingTag
        
        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)
        contentView.addSubview(dateMessageLabel)
        contentView.addSubview(delieveredTickImageView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var arrayLayouts:[NSLayoutConstraint] = []
    private var didUpdateConstraint = false
    override func updateConstraints() {
        super.updateConstraints()
        if !didUpdateConstraint {
            
            _ = arrayLayouts.map({
                $0.autoRemove()
            })
            arrayLayouts = NSLayoutConstraint.autoCreateAndInstallConstraints({ [unowned self] in
                self.createIncomingConstraints()
                })
            
            bubbleImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
            bubbleImageView.autoMatchDimension(.Width, toDimension: .Width, ofView: messageLabel).constant = 30
            bubbleImageView.autoMatchDimension(.Height, toDimension: .Height, ofView: messageLabel).constant = 15
            
            messageLabel.preferredMaxLayoutWidth = 218
            messageLabel.autoCenterInSuperview()
            
            dateMessageLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 0)
            dateMessageLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: bubbleImageView, withOffset: 4)
            
            delieveredTickImageView.autoSetDimensionsToSize(CGSize(width: 24, height: 15))
            
            delieveredTickImageView.autoAlignAxis(.Horizontal, toSameAxisOfView: dateMessageLabel)
            
            NSLayoutConstraint.autoSetPriority(245, forConstraints: { [unowned self] in
                self.dateMessageLabel.contentCompressionResistancePriorityForAxis(.Horizontal)
                })
            
            didUpdateConstraint = true
        }
    }
    
    // MARK: Private
    private let delieveredTickImageView: UIImageView
    private let dateMessageLabel: UILabel
    private let bubbleImageView: UIImageView
    private let messageLabel: UILabel
    
    private let bubbleImage: (incoming: UIImage, incomingHighlighed: UIImage, outgoing: UIImage, outgoingHighlighed: UIImage) = {
        let maskOutgoing = UIImage(named: "MessageBubble")!
        let maskIncoming = UIImage(CGImage: maskOutgoing.CGImage!, scale: 2, orientation: .UpMirrored)
        
        let capInsetsIncoming = UIEdgeInsets(top: 17, left: 26.5, bottom: 17, right: 21)
        let capInsetsOutgoing = UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 26.5)
        
        let incoming = maskIncoming.imageWithRed(229/255, green: 229/255, blue: 234/255, alpha: 1).resizableImageWithCapInsets(capInsetsIncoming)
        let incomingHighlighted = maskIncoming.imageWithRed(206/255, green: 206/255, blue: 210/255, alpha: 1).resizableImageWithCapInsets(capInsetsIncoming)
        let outgoing = maskOutgoing.imageWithRed(43/255, green: 119/255, blue: 250/255, alpha: 1).resizableImageWithCapInsets(capInsetsOutgoing)
        let outgoingHighlighted = maskOutgoing.imageWithRed(32/255, green: 96/255, blue: 200/255, alpha: 1).resizableImageWithCapInsets(capInsetsOutgoing)
        
        return (incoming, incomingHighlighted, outgoing, outgoingHighlighted)
    }()
    
    private func createIncomingConstraints() {
        bubbleImageView.autoPinEdgeToSuperviewEdge(.Left, withInset: 10)
        //            bubbleImageView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 4.5)
        
        dateMessageLabel.autoPinEdge(.Left, toEdge: .Left, ofView: bubbleImageView)
        delieveredTickImageView.autoPinEdge(.Left, toEdge: .Right, ofView: dateMessageLabel)
    }
    
    private func createOutgoingConstraints() {
        bubbleImageView.autoPinEdgeToSuperviewEdge(.Right, withInset: 10)
        dateMessageLabel.autoPinEdge(.Right, toEdge: .Right, ofView: bubbleImageView)
        delieveredTickImageView.autoPinEdge(.Right, toEdge: .Left, ofView: dateMessageLabel)
    }
    
    // MARK: Class method
    
    func configureWithMessage(message: Message) {
        messageLabel.text = message.text
        dateMessageLabel.text = self.getStringFromDate(message.sentDate, format: "h:mm a")
        self.updateConstraintsIfNeeded()
        self.setNeedsUpdateConstraints()
        if message.incoming {
            delieveredTickImageView.hidden = true
            if tag == incomingTag {
                return
            }
            tag = incomingTag
            
            
            bubbleImageView.image = self.bubbleImage.incoming
            bubbleImageView.highlightedImage = self.bubbleImage.incomingHighlighed
            messageLabel.textColor = .blackColor()
            _ = arrayLayouts.map({
                $0.autoRemove()
            })
            
            arrayLayouts = NSLayoutConstraint.autoCreateAndInstallConstraints({ [unowned self] in
                self.createIncomingConstraints()
                })
        } else {
            delieveredTickImageView.hidden = false
            delieveredTickImageView.image = message.status.getProperImage
            if tag == outgoingTag {
                return
            }
            tag = outgoingTag
            
            
            
            bubbleImageView.image = self.bubbleImage.outgoing
            bubbleImageView.highlightedImage = self.bubbleImage.outgoingHighlighed
            messageLabel.textColor = .whiteColor()
            _ = arrayLayouts.map({
                $0.autoRemove()
            })
            arrayLayouts = NSLayoutConstraint.autoCreateAndInstallConstraints({ [unowned self] in
                self.createOutgoingConstraints()
                })
        }
        
    }
    
    // Highlight cell #CopyMessage
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleImageView.highlighted = selected
    }
}

extension MessageBubbleTableViewCell: CellProtocol {
    static var cellIdentifer: String {
        return "BubbleCell"
    }
}

extension UIImage {
    
    func imageWithRed(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        self.drawInRect(rect)
        CGContextSetRGBFillColor(context, red, green, blue, alpha)
        CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
        CGContextFillRect(context, rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}