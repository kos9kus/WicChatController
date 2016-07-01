//
//  ChataCustomToolBar.swift
//  VideoSwitchboard
//
//  Created by KONSTANTIN KUSAINOV on 21/04/16.
//  Copyright © 2016 KK. All rights reserved.
//

import UIKit
import HEXColor

private let navigationHeight: CGFloat = 44
private let navigationBarButtonWidth: CGFloat = 40
private let navigationHeaderViewLeftOffSet: CGFloat = -13

private let widthDeviceScreen: CGFloat = UIScreen.mainScreen().bounds.width
private var widthHeaderView: CGFloat = 120
private var heightHeaderView: CGFloat = 20


protocol ChatCustomNavigationBarProtocol: class {
    func deleteCurrentChat()
    func popController()
    var navigationItem: UINavigationItem { get }
    var navigationController: UINavigationController? { get }
}

class ChatCustomNavigationBar<Delegate where Delegate:ChatCustomNavigationBarProtocol>: NSObject {
    
    //    var status: PresenceAgentsStatus = .PresenseAgentsStatusNone {
    //        didSet {
    //            labelStatus.text = status.status
    //            labelStatus.textColor = status.colorStatus
    //        }
    //    }
    
    weak var delegate: Delegate!
    
    init(delegate: Delegate, nameUser: String) {
        super.init()
        self.delegate = delegate
        
        let image = UIImage(named: "header-trash-ic")?.imageWithRenderingMode(.AlwaysOriginal)
        let barButton = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(didTapDeleteBarButton) )
        delegate.navigationItem.rightBarButtonItem = barButton
        
        let imageLeft = UIImage(named: "swipe_left_ic")?.imageWithRenderingMode(.AlwaysOriginal)
        let leftBarButton = UIBarButtonItem(image: imageLeft, style: .Plain, target: self, action: #selector(didTapBackButton) )
        delegate.navigationItem.leftBarButtonItem = leftBarButton
        
        labelNamePerson.text = nameUser
        
        let viewHeader = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: widthHeaderView, height: heightHeaderView) ) )
        viewHeader.addSubview(labelNamePerson)
        //        viewHeader.addSubview(labelStatus)
        
        delegate.navigationItem.titleView = viewHeader
    }
    
    // MARK: Public
    func setColorForNavigationBar() {
        defaultColorNavBar = delegate.navigationController?.navigationBar.barTintColor
        delegate.navigationController?.navigationBar.barTintColor = chatColorNavBar
    }
    
    func setDefaultBackgroundNavogationBar() {
        delegate.navigationController?.navigationBar.barTintColor = defaultColorNavBar
    }
    
    func didTapBackButton() {
        setDefaultBackgroundNavogationBar()
        delegate.popController()
    }
    
    func didTapDeleteBarButton() {
        delegate.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#fcd040")
        delegate.deleteCurrentChat()
    }
    
    // MARK: Private
    
    private let chatColorNavBar = UIColor(rgba: "#fcd040")
    private var defaultColorNavBar: UIColor?
    
    private let labelNamePerson: UILabel = {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0 ), size: CGSize(width: widthHeaderView, height: heightHeaderView) ) )
        label.font = UIFont(name: "Roboto-Regular", size: 24)
        label.textColor = .blackColor()
        label.textAlignment = .Center
        label.text = ""
        return label
    }()
    
    //    private let labelStatus: UILabel = {
    //        let label = UILabel(frame: CGRect(origin: CGPoint(x: navigationHeaderViewLeftOffSet, y: navigationHeight/2 ), size: CGSize(width: widthHeaderView, height: navigationHeight/2) ) )
    //        label.font = UIFont(name: "Helvetica", size: 14)
    //        label.textColor = .whiteColor()
    //        label.text = PresenceAgentsStatus.PresenseAgentsStatusNone.status
    //        return label
    //    }()
    
}

//extension PresenceAgentsStatus {
//    var status: String {
//        switch self {
//        case .PresenseAgentsStatusOffline:
//            return NSLocalizedString("Unavailable", comment: "USER_STATUS_UNAVAILABLE")
//        case .PresenseAgentsStatusActive:
//            return NSLocalizedString("Available", comment: "USER_STATUS_AVAILABLE")
//        case .PresenseAgentsStatusIdle:
//            return NSLocalizedString("Inactive", comment: "USER_STATUS_INACTIVE")
//        case PresenseAgentsStatusNone:
//            return ""
//        }
//    }
//
//    var colorStatus: UIColor {
//        switch self {
//        case .PresenseAgentsStatusOffline:
//            return CustomColor.agentUnavailable()
//        case .PresenseAgentsStatusActive:
//            return CustomColor.agentAvailable()
//        case .PresenseAgentsStatusIdle:
//            return CustomColor.agentInactive()
//        case PresenseAgentsStatusNone:
//            return .clearColor()
//        }
//    }
//}
