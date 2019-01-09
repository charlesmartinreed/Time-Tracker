//
//  HistoryInterfaceController.swift
//  WatchOS fun WatchKit Extension
//
//  Created by Charles Martin Reed on 1/8/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import WatchKit

class HistoryInterfaceController: WKInterfaceController {
    
    //MARK:- IBOutlet
    @IBOutlet weak var table: WKInterfaceTable!
    
    //MARK:- Properties
    var clockIns = [Date]()
    var clockOuts = [Date]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //filling out the tableView
        if let clockIns = UserDefaults.standard.array(forKey: "clockInLog") as? [Date] {
            self.clockIns = clockIns
        }
        
        if let clockOuts = UserDefaults.standard.array(forKey: "clockOutLog") as? [Date] {
            self.clockOuts = clockOuts
        }
        
        //tell the table controller how many rows to produce
        table.setNumberOfRows(clockIns.count, withRowType: "InOutRow")
        
        //getting the row controller with WatchOS
        for i in 0..<clockIns.count {
            if let rowController = table.rowController(at: i) as? ClockInAndOutRowController {
                //specifying the contents of the cell at the row
                let clockOut = clockOuts[i]
                let clockIn = clockIns[i]
                let rowContents = formatTime(clockOut: clockOut, clockIn: clockIn)
                rowController.label.setText(rowContents)
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        //push over to the detail scrreen for each individual log, passing the clocked in and clocked out times for the tapped row as the "
        pushController(withName: "timeDetails", context: ["clockedIn": clockIns[rowIndex], "clockedOut": clockOuts[rowIndex]])
    }
    
    //MARK:- Formatting time interval for layout in table
    func formatTime(clockOut: Date, clockIn: Date) -> String {
            let timeInterval = Int(clockOut.timeIntervalSince(clockIn))
            var timeString = ""
        
            let hours = timeInterval / 3600 //60 secs * 60 minutes, we're dealing with seconds via our Int
            let minutes = (timeInterval % 3600) / 60
            let seconds = timeInterval % 60
        
        if hours != 0 {
            timeString += "\(hours)h"
        }
        
        if hours != 0 || minutes != 0 {
            timeString += "\(minutes)m"
        }

        timeString += "\(seconds)s"
        
        return timeString
    }
}
