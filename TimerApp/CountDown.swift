//
//  CountDown.swift
//  TimerApp
//
//  Created by D4ttatraya on 17/11/22.
//

import Foundation

protocol CountDown {
    func start(withTimeInterval: TimeInterval, completion: @escaping () -> Void)
    func stop()
}

class CountDownWorker: CountDown {
    
    func start(withTimeInterval interval: TimeInterval, completion: @escaping () -> Void) {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            completion()
        }
    }
    
    func stop() {
        self.timer?.invalidate()
    }
    
    //MARK: - Private -
    private var timer: Timer?
}
