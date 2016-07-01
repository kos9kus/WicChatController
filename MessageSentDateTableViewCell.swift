
import UIKit
import PureLayout

private let kMessageSentDateTableViewCellDateLabelInset: CGFloat = 4

class MessageSentDateTableViewCell: UITableViewCell, CellProtocol {
    
    var date: NSDate = NSDate() {
        didSet {
            let dateString = self.getStringFromDate(date, format: "MMMM dd")
            if dateString == self.getStringFromDate(NSDate(), format: "MMMM dd") {
                sentDateLabel.text = NSLocalizedString("Today", comment: "dateString of chat message")
            } else {
                sentDateLabel.text = dateString
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        sentDateLabel = UILabel(frame: CGRectZero)
        sentDateLabel.backgroundColor = .whiteColor()
        sentDateLabel.font = UIFont.systemFontOfSize(10)
        sentDateLabel.textAlignment = .Center
        sentDateLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)
        sentDateLabel.text = "Today"
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.addSubview(sentDateLabel)
        
//        self.setlayoutifNeeded()
//        print("\(#function) + \(self.frame)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var didUpdateayout = false
    override func updateConstraints() {
        super.updateConstraints()
        if !didUpdateayout {
            sentDateLabel.autoSetDimension(ALDimension.Width, toSize: 100, relation: NSLayoutRelation.GreaterThanOrEqual)
            sentDateLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: kMessageSentDateTableViewCellDateLabelInset)
            sentDateLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: kMessageSentDateTableViewCellDateLabelInset)
            sentDateLabel.autoCenterInSuperview()
            didUpdateayout = true
        }
//        print("\(#function) + \(self.frame)")
    }
    
//    override func layoutSubviews() {
//        print("\(#function) + \(self.frame)")
//    }
    
    override func drawRect(rect: CGRect) {
//        print("\(#function) + \(self.frame)")
        
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 0, y: rect.height / 2 ) )
        bezierPath.addLineToPoint(CGPoint(x: rect.width, y: rect.height / 2) )
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = UIColor.lightGrayColor().CGColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [ 3, 3 ]
        shapeLayer.path = bezierPath.CGPath
        
        contentView.layer.insertSublayer(shapeLayer, atIndex: 0)
    }
    
    // MARK: Private
    private let sentDateLabel: UILabel
    
}

extension MessageSentDateTableViewCell {
    static var cellIdentifer: String {
        return "SentDateCell"
    }
}