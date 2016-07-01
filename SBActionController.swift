//
//  SBActionController.swift
//  VideoSwitchboard
//
//  Created by KONSTANTIN KUSAINOV on 22/04/16.
//  Copyright © 2016 KK. All rights reserved.
//

import UIKit

class SBActionController<Delegate: UIViewController>: NSObject {
    
    static func presentYesNoActionController(delegate: UIViewController, title: String, message: String, agreeBlock: () -> Void) {
        let actionController = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .Alert)
        
        let actionYes = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .Default) { (action) in
            agreeBlock()
        }
        
        let actionNo = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Cancel, handler: nil)
        
        actionController.addAction(actionYes)
        actionController.addAction(actionNo)
        delegate.presentViewController(actionController, animated: true, completion: nil)
    }
}
