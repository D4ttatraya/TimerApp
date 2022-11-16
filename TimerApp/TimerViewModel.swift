//
//  TimerViewModel.swift
//  TimerApp
//
//  Created by D4ttatraya on 16/11/22.
//

import Foundation

enum TimerState: Equatable {
    case stopped
    case active(Date)
    case paused(Float)
}

protocol TimerViewModel: ObservableObject {
    var time: String { get }
    var timerCompletion: Float { get }
    var state: TimerState { get }
    var showTimerCompletionAlert: Bool { get set }
    func startTimer(minutes: Float)
    func pauseTimer()
    func resumeTimer()
    func stopTimer()
}

let DefaultTimerMinutes: Float = 5.0

class TimerViewModelImplementation: TimerViewModel {
    
    @Published var state: TimerState = .stopped
    @Published var showTimerCompletionAlert = false
    @Published var timerCompletion = DefaultTimerMinutes
    @Published var time = "\(DefaultTimerMinutes):00"
    
    init(worker: TimerWorker?) {
        self.worker = worker
        
        if let time = worker?.getTime() {
            self.initialSeconds = time.initialTime
            self.state = .paused(time.timeRemaining)
            self.updateTimer(timeRemaining: time.timeRemaining)
        }
        worker?.clearTime()
    }
    
    func startTimer(minutes: Float) {
        self.initialSeconds = minutes * 60
        guard let endDate = Calendar.current.date(byAdding: .minute, value: Int(minutes), to: Date()) else {
            return
        }
        self.state = .active(endDate)
        self.startUpdatingTimer()
    }
    
    func pauseTimer() {
        guard case .active(let endDate) = self.state  else {
            return
        }
        self.timer?.invalidate()
        //save current progress and initialSeconds in DB
        let diff = endDate.timeIntervalSince1970 - Date().timeIntervalSince1970
        let time = (self.initialSeconds, Float(diff))
        self.worker?.save(time: time)
        self.state = .paused(Float(diff))
    }
    
    func resumeTimer() {
        guard case .paused(let timeRemaining) = self.state  else {
            return
        }
        guard let endDate = Calendar.current.date(byAdding: .second, value: Int(timeRemaining), to: Date()) else {
            return
        }
        self.state = .active(endDate)
        self.startUpdatingTimer()
    }
    
    func stopTimer() {
        self.state = .stopped
    }
    
    //MARK: - Private -
    private let worker: TimerWorker?
    private var initialSeconds: Float = 0.0
    private var timer: Timer?
    
    private func startUpdatingTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            guard case .active(let endDate) = self.state  else {
                return
            }
            
            let diff = endDate.timeIntervalSince1970 - Date().timeIntervalSince1970
            guard diff > 0 else {
                self.state = .stopped
                self.showTimerCompletionAlert = true
                self.timer?.invalidate()
                self.timer = nil
                return
            }
            
            self.updateTimer(timeRemaining: Float(diff))
        }
    }
    
    private func updateTimer(timeRemaining diff: Float) {
        let minutes = Int(diff / 60)
        let seconds = diff.truncatingRemainder(dividingBy: 60)
//        let miliSeconds = Int(diff * 1000)
        self.timerCompletion = diff / self.initialSeconds
        self.time = String(format:"%d:%.3f", minutes, seconds)
    }
}
