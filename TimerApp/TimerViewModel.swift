//
//  TimerViewModel.swift
//  TimerApp
//
//  Created by D4ttatraya on 16/11/22.
//

import Foundation

protocol TimerViewModel: ObservableObject {
    var time: String { get }
    var timerCompletion: Float { get }
    var timerModel: TimerModel { get }
    var showTimerCompletionAlert: Bool { get set }
    func startTimer(minutes: Float)
    func pauseTimer()
    func resumeTimer()
    func stopTimer()
    func pauseUIUpdates()
    func resumeUIUpdates()
}

let DefaultTimerMinutes: Float = 5.0

class TimerViewModelClass: TimerViewModel {
    
    @Published var timerModel = TimerModel(duration: 0, state: .stopped)
    @Published var showTimerCompletionAlert = false
    @Published var timerCompletion = DefaultTimerMinutes
    @Published var time = "\(DefaultTimerMinutes):00"
    
    init(timerData: TimerData?, countDown: CountDown?) {
        self.timerData = timerData
        self.countDown = countDown
        self.refreshTimerStatus()
    }
    
    func startTimer(minutes: Float) {
        let seconds = minutes * 60
        guard let endDate = Calendar.current.date(byAdding: .second, value: Int(seconds), to: Date()) else {
            return
        }
        self.timerModel = TimerModel(duration: seconds,
                                     state: .active(endDate: endDate))
        self.timerData?.saveAndSchedule(timer: self.timerModel)
        self.startUpdatingTimer()
    }
    
    func pauseTimer() {
        guard case .active(let endDate) = self.timerModel.state else {
            return
        }
        self.countDown?.stop()
        //save current progress and initialSeconds in DB
        let diff = endDate.timeIntervalSince1970 - Date().timeIntervalSince1970
        self.timerModel.state = .paused(timeRemaining: Float(diff))
        self.timerData?.pause(timer: self.timerModel)
    }
    
    func resumeTimer() {
        guard case .paused(let timeRemaining) = self.timerModel.state  else {
            return
        }
        guard let endDate = Calendar.current.date(byAdding: .second, value: Int(timeRemaining), to: Date()) else {
            return
        }
        self.timerModel.state = .active(endDate: endDate)
        self.timerData?.saveAndSchedule(timer: self.timerModel)
        self.startUpdatingTimer()
    }
    
    func stopTimer() {
        self.timerData?.removeTimer()
        self.timerModel.state = .stopped
    }
    
    func pauseUIUpdates() {
        self.countDown?.stop()
    }
    
    func resumeUIUpdates() {
        self.refreshTimerStatus()
    }
    
    //MARK: - Private -
    private let timerData: TimerData?
    private var countDown: CountDown?
    
    private func refreshTimerStatus() {
        guard let timer = self.timerData?.getTimer() else {
            return
        }
        self.timerModel = timer
        if case .active(let endDate) = timer.state {
            let diff = endDate.timeIntervalSince1970 - Date().timeIntervalSince1970
            if diff <= 0 {
                self.timerModel.state = .stopped
                self.timerData?.removeTimer()
            } else {
                self.startUpdatingTimer()
            }
        } else if case .paused(let timeRemaining) = timer.state {
            self.updateTimer(timeRemaining: timeRemaining)
        }
    }
    
    private func startUpdatingTimer() {
        guard case .active(let endDate) = self.timerModel.state  else {
            return
        }
        
        self.countDown?.start(withTimeInterval: 0.01) { [unowned self] in
            
            let diff = endDate.timeIntervalSince1970 - Date().timeIntervalSince1970
            guard diff > 0 else {
                self.timerModel.state = .stopped
                self.showTimerCompletionAlert = true
                self.countDown?.stop()
                self.timerData?.removeTimer()
                return
            }
            
            self.updateTimer(timeRemaining: Float(diff))
        }
    }
    
    private func updateTimer(timeRemaining diff: Float) {
        let minutes = Int(diff / 60)
        let seconds = diff.truncatingRemainder(dividingBy: 60)
//        let miliSeconds = Int(diff * 1000)
        self.timerCompletion = diff / self.timerModel.duration
        self.time = String(format:"%d:%.3f", minutes, seconds)
    }
}
