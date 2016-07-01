//
//  CellsProtocol.swift
//  DSSBKKChatController
//
//  Created by kkusain on 05/04/16.
//  Copyright © 2016 LLC.86Borders. All rights reserved.
//

import Foundation

protocol CellProtocol: class {
    static var cellIdentifer: String { get }
}


extension CellProtocol {
    func getStringFromDate(date: NSDate, format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(date)
    }
}
