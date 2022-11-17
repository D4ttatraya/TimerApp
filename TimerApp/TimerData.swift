//
//  TimerWorker.swift
//  TimerApp
//
//  Created by D4ttatraya on 16/11/22.
//

import Foundation
import UserNotifications

enum TimerState: Equatable {
    case stopped
    case active(endDate: Date)
    case paused(timeRemaining: Float)
}

struct TimerModel {
    let duration: Float//seconds
    var state: TimerState
}
protocol TimerData {
    func saveAndSchedule(timer: TimerModel)
    func pause(timer: TimerModel)
    func getTimer() -> TimerModel?
    func removeTimer()
}

struct TimerDataWorker: TimerData {
    
    init() {
        TimerDataWorker.handleNotificationPermissions()
    }
    
    func saveAndSchedule(timer: TimerModel) {
        guard case .active(_) = timer.state  else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "Timer Done ⏰"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        
        let interval = TimeInterval(timer.duration)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                let errorStr = "Error occurred scheduling notification: \(error)"
                print(errorStr)
            } else {
                print("Notification scheduled")
            }
        }
        self.save(timer: timer)
    }
    
    func pause(timer: TimerModel) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        self.save(timer: timer)
    }
    
    func getTimer() -> TimerModel? {
        let duration = UserDefaults.standard.float(forKey: Keys.Duration)
        let endDate = UserDefaults.standard.object(forKey: Keys.EndDate) as? Date
        let timeRemaining = UserDefaults.standard.float(forKey: Keys.TimeRemainingAfterPause)
        guard duration > 0 else {
            return nil
        }
        if let endDate = endDate {
            return TimerModel(duration: duration, state: .active(endDate: endDate))
        } else if timeRemaining > 0 {
            return TimerModel(duration: duration, state: .paused(timeRemaining: timeRemaining))
        }
        return nil
    }
    
    func removeTimer() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        self.clearTimer()
    }
    
    static func handleNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if let error = error {
                        print("Something went wrong: \(error.localizedDescription)")
                    } else {
                        print("Got notification permissions")
                    }
                }
            } else if settings.authorizationStatus == .denied {
                let error = "It seems that notifications are disabled. To deliver Time Check alerts enable notifications from your device settings"
                print(error)
            } else if settings.authorizationStatus == .authorized {
                if settings.alertSetting == .disabled {
                    let error = "It seems that notification banners are disabled. To deliver Time Check alerts enable banners from your device settings"
                    print(error)
                } else {
                    print("Already got notification permissions")
                }
            }
        }
    }
    
    //MARK: - Private -
    private struct Keys {
        static let Duration = "TimerDuration"
        static let EndDate = "TimerEndDate"
        static let TimeRemainingAfterPause = "TimeRemainingAfterPause"
    }
    
    private func save(timer: TimerModel) {
        UserDefaults.standard.set(timer.duration, forKey: Keys.Duration)
        if case .active(let endDate) = timer.state {
            UserDefaults.standard.set(endDate, forKey: Keys.EndDate)
            UserDefaults.standard.removeObject(forKey: Keys.TimeRemainingAfterPause)
        } else if case .paused(let timeRemaining) = timer.state {
            UserDefaults.standard.set(timeRemaining, forKey: Keys.TimeRemainingAfterPause)
            UserDefaults.standard.removeObject(forKey: Keys.EndDate)
        }
    }
    
    private func clearTimer() {
        UserDefaults.standard.removeObject(forKey: Keys.Duration)
        UserDefaults.standard.removeObject(forKey: Keys.EndDate)
        UserDefaults.standard.removeObject(forKey: Keys.TimeRemainingAfterPause)
    }
}
