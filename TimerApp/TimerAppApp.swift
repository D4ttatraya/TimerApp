//
//  TimerAppApp.swift
//  TimerApp
//
//  Created by D4ttatraya on 16/11/22.
//

import SwiftUI

@main
struct TimerAppApp: App {
    var body: some Scene {
        WindowGroup {
            let timerVM = TimerViewModelImplementation(worker: TimerDatabase())
            TimerView(vm: timerVM)
        }
    }
}
