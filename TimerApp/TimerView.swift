//
//  TimerView.swift
//  TimerApp
//
//  Created by D4ttatraya on 16/11/22.
//

import SwiftUI

struct TimerView<ViewModel>: View where ViewModel: TimerViewModel {
    
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var vm: ViewModel
    @State var timerMinutes = DefaultTimerMinutes
    
    var body: some View {
        VStack {
            Group {
                if vm.timerModel.state == .stopped {
                    VStack {
                        Slider(value: $timerMinutes, in: 1...20, step: 1)
                        
                        Text("\(Int(self.timerMinutes)):00")
                            .font(Font.title.monospacedDigit())
                    }
                } else {
                    ZStack {
                        TimerProgressView(progress: vm.timerCompletion)
                        
                        Text(vm.time)
                            .font(Font.title.monospacedDigit())
                    }
                }
            }
            .frame(width: 300, height: 300)
            .padding(.bottom, 40)
            
            HStack {
                Button {
                    vm.stopTimer()
                } label: {
                    Text("Stop")
                        .font(Font.title2)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(vm.timerModel.state == .stopped ? .gray : .primary)
                        .cornerRadius(10)
                }
                .disabled(vm.timerModel.state == .stopped)
                
                Spacer().frame(width: 40)
                
                Button {
                    switch vm.timerModel.state {
                    case .stopped: vm.startTimer(minutes: self.timerMinutes)
                    case .active(_): vm.pauseTimer()
                    case .paused(_): vm.resumeTimer()
                    }
                } label: {
                    Text(vm.timerModel.state.mainButtonTitle)
                        .font(Font.title2)
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(Color.green)
                        .cornerRadius(10)
                }
            }
        }
        .alert("Timer Done ???", isPresented: $vm.showTimerCompletionAlert) {
            Button("Okay", role: .cancel) {}
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive {
                vm.pauseUIUpdates()
            } else if newPhase == .active {
                vm.resumeUIUpdates()
            }
        }
    }
}

fileprivate extension TimerState {
    var mainButtonTitle: String {
        switch self {
        case .stopped: return "Start"
        case .active(_): return "Pause"
        case .paused(_): return "Resume"
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(vm: TimerViewModelClass(timerData: nil, countDown: CountDownWorker()))
    }
}
