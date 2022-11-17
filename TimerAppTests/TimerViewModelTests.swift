//
//  TimerViewModelTests.swift
//  TimerAppTests
//
//  Created by D4ttatraya on 16/11/22.
//

import XCTest
@testable import TimerApp

final class TimerViewModelTests: XCTestCase {
    
    private let DateInFuture = Date(timeInterval: 30, since: Date())
    private let DateInPast = Date(timeInterval: -30, since: Date())
    
    func testTimerVM_IfPaused_StopsCountDown() {
        //given
        let countDown = DummyCountDown()
        let vm = TimerViewModelClass(timerData: nil, countDown: countDown)
        vm.startTimer(minutes: 1.0)
        XCTAssertTrue(countDown.started)
        
        //when
        vm.pauseTimer()
        
        //then
        XCTAssertFalse(countDown.started)
    }
    
    func testTimerVM_IfCountDownFinished_StopsTimerAndShowsAlert() {
        //given
        let countDown = DummyCountDown()
        let vm = TimerViewModelClass(timerData: nil, countDown: countDown)
        vm.startTimer(minutes: 0.017)//~1sec in future
        XCTAssertFalse(vm.showTimerCompletionAlert)
        XCTAssertNotEqual(vm.timerModel.state, .stopped)
        
        let exp = expectation(description: "Test after 1seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            //when
            countDown.flush()
            
            //then
            XCTAssertTrue(vm.showTimerCompletionAlert)
            XCTAssertEqual(vm.timerModel.state, .stopped)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testTimerVM_WhenInitializing_SetsCorrectState() {
        //found no timer in DB
        var dummyData = DummyData()//given
        var vm = TimerViewModelClass(timerData: dummyData, countDown: nil)//when
        XCTAssertEqual(vm.timerModel.state, .stopped)//then
        
        //found active but expired timer in DB
        dummyData = DummyData(state: .active(endDate: DateInPast))
        vm = TimerViewModelClass(timerData: dummyData, countDown: nil)
        XCTAssertEqual(vm.timerModel.state, .stopped)
        
        //found active timer in DB
        dummyData = DummyData(state: .active(endDate: DateInFuture))
        vm = TimerViewModelClass(timerData: dummyData, countDown: nil)
        if case .active(_) = vm.timerModel.state {
        } else {
            XCTFail("State must be active")
        }
        
        //found paused timer in DB
        dummyData = DummyData(state: .paused(timeRemaining: 30))
        vm = TimerViewModelClass(timerData: dummyData, countDown: nil)
        if case .paused(let timeRemaining) = vm.timerModel.state {
            XCTAssertEqual(timeRemaining, 30)
        } else {
            XCTFail("State must be active")
        }
    }

    func testTimerVM_IfTimerStarted_SavesCorrectState() {
        //given
        let dummyData = DummyData()
        let vm = TimerViewModelClass(timerData: dummyData, countDown: nil)
        XCTAssertNil(dummyData.state)
        
        //when
        vm.startTimer(minutes: 1.0)
        
        //then
        if case .active(_) = dummyData.state {
        } else {
            XCTFail("State must be active")
        }
    }
    
    func testTimerVM_IfTimerPaused_SavesCorrectState() {
        let dummyData = DummyData()
        let vm = TimerViewModelClass(timerData: dummyData, countDown: nil)
        vm.startTimer(minutes: 1.0)
        
        vm.pauseTimer()
        
        if case .paused(_) = dummyData.state {
        } else {
            XCTFail("State must be paused")
        }
    }
    
    func testTimerVM_IfTimerResumed_SavesCorrectState() {
        let dummyData = DummyData()
        let vm = TimerViewModelClass(timerData: dummyData, countDown: nil)
        vm.startTimer(minutes: 1.0)
        vm.pauseTimer()
        
        vm.resumeTimer()
        
        if case .active(_) = dummyData.state {
        } else {
            XCTFail("State must be active")
        }
    }

}

fileprivate class DummyData: TimerData {
    
    private (set) var state: TimerState? = nil
    init(state: TimerState? = nil) {
        self.state = state
    }
    
    func saveAndSchedule(timer: TimerApp.TimerModel) {
        self.state = timer.state
    }
    
    func pause(timer: TimerApp.TimerModel) {
        self.state = timer.state
    }
    
    func getTimer() -> TimerApp.TimerModel? {
        guard let state = self.state else {
            return nil
        }
        return TimerModel(duration: 30, state: state)
    }
    
    func removeTimer() {
        
    }
}

fileprivate class DummyCountDown: CountDown {
    
    private (set) var started = false
    private (set) var completion: (() -> Void)?
    
    func start(withTimeInterval: TimeInterval, completion: @escaping () -> Void) {
        self.started = true
        self.completion = completion
    }
    
    func stop() {
        self.started = false
    }
    
    //Helpers
    func flush() {
        self.completion?()
    }
}
