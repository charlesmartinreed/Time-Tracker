//
//  DetailInterfaceController.swift
//  WatchOS fun WatchKit Extension
//
//  Created by Charles Martin Reed on 1/8/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import WatchKit
import Foundation


class DetailInterfaceController: WKInterfaceController {

    //MARK:- IBOutlets
    @IBOutlet weak var clockInLabel: WKInterfaceLabel!
    @IBOutlet weak var clockOutLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        //passed dict looks like this: ["clockedIn": clockIns[rowIndex], "clockedOut": clockOuts[rowIndex]
        
        //grab the times
        if let dates = context as? [String: Date] {
            if let clockIn = dates["clockedIn"] {
                if let clockOut = dates["clockedOut"] {
                    //these are actual date objects, let's format them
                    let (inDate, outDate) = formatDatesFor(clockIn: clockIn, clockOut: clockOut)
                    //update the labels
                    clockInLabel.setText(inDate)
                    clockOutLabel.setText(outDate)
                }
            }
        }
    }
    
    func formatDatesFor(clockIn: Date, clockOut: Date) -> (String, String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd H:mma" //months, day, hours, AM/PM
        
        return ((dateFormatter.string(from: clockIn )), dateFormatter.string(from: clockOut))
    }

}
