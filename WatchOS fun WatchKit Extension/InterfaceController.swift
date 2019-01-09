//
//  InterfaceController.swift
//  WatchOS fun WatchKit Extension
//
//  Created by Charles Martin Reed on 1/8/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var topLabel: WKInterfaceLabel!
    @IBOutlet weak var middleLabel: WKInterfaceLabel!
    @IBOutlet weak var clockInOutButton: WKInterfaceButton!
    
    //MARK:- Properties
    var clockedIn = false
    var timer: Timer?
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //check to see if user is already clocked in
        if UserDefaults.standard.value(forKey: "clockedIn") != nil {
            clockedIn = true
            
            if timer == nil {
                startTimer()
            }
        } else {
            clockedIn = false
        }
        
        updateUI()
    }
    
    //MARK:- IBActions
    @IBAction func clockInOutButtonTapped() {
        if clockedIn {
            clockOut()
        } else {
            clockIn()
        }
        
        clockedIn.toggle()
        updateUI()
    }
    
    func clockIn() {
        
        UserDefaults.standard.set(Date(timeIntervalSinceNow: -5000), forKey: "clockedIn")
        UserDefaults.standard.synchronize()
        startTimer()
    }
    
    func clockOut() {
        //reset the timer
        timer?.invalidate()
        timer = nil
        
        if let clockedInDate = UserDefaults.standard.value(forKey: "clockedIn") as? Date {
            //check for the clock-in/clock-out array
            if var clockInLog = UserDefaults.standard.array(forKey: "clockInLog") as? [Date] {
                //if there's an array of values
                clockInLog.insert(clockedInDate, at: 0)
                UserDefaults.standard.set(clockInLog, forKey: "clockInLog")
            } else {
                //only when there's no array
                UserDefaults.standard.set([clockedInDate], forKey: "clockInLog")
            }
        
            if var clockOutLog = UserDefaults.standard.array(forKey: "clockOutLog") as? [Date] {
                //if there's an array of values, insert the current time into UserDefaults
                clockOutLog.insert(Date(), at: 0)
                UserDefaults.standard.set(clockOutLog, forKey: "clockOutLog")
            } else {
                //only when there's no array
                UserDefaults.standard.set([Date()], forKey: "clockOutLog")
            }
            
            UserDefaults.standard.set(nil, forKey: "clockedIn")
            UserDefaults.standard.synchronize()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            // Update various labels
            self.updateUI()
        }
        
    }
    
    func updateUI() {
        
        //update the current time
        if clockedIn {
            topLabel.setHidden(false)
            topLabel.setText("Today: \(totalTimeWorkedAsString())")
            
            //middle label
            //get current clock in date
            if let clockedInDate = UserDefaults.standard.value(forKey: "clockedIn") as? Date {
                //convert to time interval
                let timeInterval = Int(Date().timeIntervalSince(clockedInDate))
                
                let hours = timeInterval / 3600 //60 secs * 60 minutes, we're dealing with seconds via our Int
                let minutes = (timeInterval % 3600) / 60
                let seconds = timeInterval % 60
                
                var currentClockedInString = ""
                
                if hours != 0 {
                  currentClockedInString += "\(hours)h\n "
                }
                
                if minutes != 0 || hours != 0 {
                    currentClockedInString += "\(minutes)m "
                }
                
                currentClockedInString += "\(seconds)s "
                //currentClockedInString.append("\(seconds)s ")
                
                middleLabel.setText(currentClockedInString)
            }
            
            clockInOutButton.setTitle("Clock-Out")
            clockInOutButton.setBackgroundColor(.red)
        } else {
            topLabel.setHidden(true)
            
            //middle label
            middleLabel.setText("Today: \n\(totalTimeWorkedAsString())")
            
            clockInOutButton.setTitle("Clock-In")
            clockInOutButton.setBackgroundColor(.green)
        }
        
        
    }
    
    func totalClockedTime() -> Int {
        //determine the current clocked in time
        if var clockedInLog = UserDefaults.standard.array(forKey: "clockInLog") as? [Date] {
            if var clockedOutLog = UserDefaults.standard.array(forKey: "clockOutLog") as? [Date] {
                var seconds = 0
                
                //loop through the arrays
                for i in 0..<clockedInLog.count {
                    seconds += Int(clockedOutLog[i].timeIntervalSince(clockedInLog[i]))
                }
                
                return seconds
            }
        }
        //if there's nothing available in UserDefaults yet
        return 0
    }
    
    func totalTimeWorkedAsString() -> String {
        var currentClockedInSeconds = 0
        
        if let clockedInDate = UserDefaults.standard.value(forKey: "clockedIn") as? Date {
            currentClockedInSeconds = Int(Date().timeIntervalSince(clockedInDate))
        }
        
        let totalTimeInterval = currentClockedInSeconds + totalClockedTime()
        
        //convert to hours minutes and seconds
        let totalHours = totalTimeInterval / 3600
        let totalMinutes = (totalTimeInterval % 3600) / 60
        
        return "\(totalHours)h \(totalMinutes)m"
    }
    
    
    
    //MARK:- Menu actions
    @IBAction func historyTapped() {
        //this is the WatchOS equivalent of segue
        pushController(withName: "History", context: nil)
   
    }
    
    @IBAction func resetAllTapped() {
        //set everything in UserDefaults back to 0
        UserDefaults.standard.set(nil, forKey: "clockedIn")
        UserDefaults.standard.set(nil, forKey: "clockInLog")
        UserDefaults.standard.set(nil, forKey: "clockOutLog")
        
        clockedIn = false
        
        //update the UI to reflect the changes
        updateUI()
    }
    
    
}
