//
//  TimerWorker.swift
//  TimerApp
//
//  Created by D4ttatraya on 16/11/22.
//

import Foundation

typealias Time = (initialTime: Float, timeRemaining: Float)
protocol TimerWorker {
    func save(time: Time)
    func getTime() -> Time?
    func clearTime()
}

struct TimerDatabase: TimerWorker {
    
    func save(time: Time) {
        UserDefaults.standard.set(time.initialTime, forKey: Keys.Initial)
        UserDefaults.standard.set(time.timeRemaining, forKey: Keys.Remaining)
    }
    
    func getTime() -> Time? {
        let initialTime = UserDefaults.standard.float(forKey: Keys.Initial)
        let timeRemaining = UserDefaults.standard.float(forKey: Keys.Remaining)
        guard initialTime > 0 && timeRemaining > 0 else {
            return nil
        }
        return (initialTime, timeRemaining)
    }
    
    func clearTime() {
        UserDefaults.standard.removeObject(forKey: Keys.Initial)
        UserDefaults.standard.removeObject(forKey: Keys.Remaining)
    }
    
    //MARK: - Private -
    struct Keys {
        static let Initial = "InitialSeconds"
        static let Remaining = "RemainingSeconds"
    }
}
