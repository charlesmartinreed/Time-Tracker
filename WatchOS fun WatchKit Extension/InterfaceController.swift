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
            print("SOMETHING IS THERE")
            clockedIn = true
            
            if timer == nil {
                startTimer()
            }
        } else {
            print("NOTHING IS THERE")
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
    
    fileprivate func clockIn() {
        UserDefaults.standard.set(Date(), forKey: "clockedIn")
        //UserDefaults.standard.synchronize() - Swift documentation mentinos this method is useless and shouldn't
        startTimer()
    }
    
    fileprivate func clockOut() {
        //reset the timer
        timer?.invalidate()
        timer = nil
        
        if let clockedInDate = UserDefaults.standard.value(forKey: "clockedIn") as? Date {
            //check for the clock-in/clock-out array
            if var clockInLog = UserDefaults.standard.array(forKey: "clockInLog") as? [Date] {
                //if there's an array of values
                clockInLog.insert(clockedInDate, at: 0)
                UserDefaults.standard.set([clockInLog], forKey: "clockInLog")
            } else {
                //only when there's no array
                UserDefaults.standard.set([clockedInDate], forKey: "clockInLog")
            }
        
            if var clockOutLog = UserDefaults.standard.array(forKey: "clockOutLog") as? [Date] {
                //if there's an array of values, insert the current time into UserDefaults
                clockOutLog.insert(Date(), at: 0)
                UserDefaults.standard.set([clockOutLog], forKey: "clockOutLog")
            } else {
                //only when there's no array
                UserDefaults.standard.set([Date()], forKey: "clockOutLog")
            }
            
            UserDefaults.standard.set(nil, forKey: "clockedIn")
            //UserDefaults.standard.synchronize()
        }
    }
    
    fileprivate func updateUI() {
        
        //update the current time
        if clockedIn {
            topLabel.setHidden(false)
            topLabel.setText("Today: 3h 45m")
            
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
                  currentClockedInString.append("\(hours)h ")
                }
                
                if minutes != 0 || hours != 0 {
                    currentClockedInString.append("\(minutes)m ")
                }
                
                currentClockedInString.append("\(seconds)s ")
                
                middleLabel.setText(currentClockedInString)
            }
            
            clockInOutButton.setTitle("Clock-Out")
            clockInOutButton.setBackgroundColor(.red)
        } else {
            topLabel.setHidden(true)
            
            //middle label
            middleLabel.setText("Today: \n3h 44m")
            
            clockInOutButton.setTitle("Clock-In")
            clockInOutButton.setBackgroundColor(.green)
        }
        
        
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            // Update various labels
            self.updateUI()
        }
        
    }
    
    //MARK:- Menu actions
    @IBAction func historyTapped() {
   
    }
    
    @IBAction func resetAllTapped() {
    
    }
    
    
}
