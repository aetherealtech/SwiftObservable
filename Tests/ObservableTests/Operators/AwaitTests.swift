//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Scheduling
import Observer

@testable import Observable

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class AwaitTests: XCTestCase {

    class TestObservables {

        let initialValue = 10
        
        @MockObservable var source: Task<Int, Never> = AwaitTests.intTask(value: 8)

        @AnyObservable var awaited: Int

        let scheduler = MockScheduler()

        init() {

            let channel = SimpleChannel<Task<Int, Never>>()

            let source = _source

            source.setWrappedValueSetup = { newValue in

                source.getWrappedValueSetup = { newValue }
                channel.publish(newValue)
            }

            source.subscribeSetup = channel.subscribe

            _awaited = source
                .await(initialValue: initialValue, on: scheduler)
        }
    }
    
    func testValue() async throws {

        let observables = TestObservables()

        XCTAssertEqual(observables.awaited, observables.initialValue)
        
        _ = await observables.source.value
        try! await Task.sleep(nanoseconds: 100000)

        observables.scheduler.process()
        observables.scheduler.reset()
        
        for value in 0..<10 {

            let oldTask = observables.source

            let newTask = Self.intTask(value: value)

            observables.source = newTask
            
            let oldValue = await oldTask.value
            let newValue = await newTask.value
            try! await Task.sleep(nanoseconds: 100000)
        
            XCTAssertEqual(observables.scheduler.runInvocations.count, 1)
            XCTAssertEqual(observables.awaited, oldValue)

            observables.scheduler.process()
            XCTAssertEqual(observables.awaited, newValue)

            observables.scheduler.reset()
        }
    }
    
    func testUpdate() async throws {

        await validateUpdates(includeInitial: false)
    }
    
    func testUpdateWithInitial() async throws {

        await validateUpdates(includeInitial: true)
    }

    private static func intTask(value: Int) -> Task<Int, Never> {

        Task {

            try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<10000))

            return value
        }
    }

    private func validateUpdates(includeInitial: Bool) async {
        
        let observables = TestObservables()

        var receivedValues = [Int]()
        
        let subscription = observables.$awaited
            .subscribe(notifyImmediately: includeInitial) { value in

                receivedValues.append(value)
            }
        
        var expectedValues = [Int]()

        let firstValue = await observables.source.value
        try! await Task.sleep(nanoseconds: 100000)
        
        observables.scheduler.process()
        observables.scheduler.reset()

        expectedValues.append(firstValue)
        
        for value in 0..<10 {

            let currentReceivedValues = receivedValues
            observables.source = Self.intTask(value: value)
            XCTAssertEqual(receivedValues, currentReceivedValues)

            _ = await observables.source.value
            try! await Task.sleep(nanoseconds: 100000)
            
            observables.scheduler.process()
            observables.scheduler.reset()

            expectedValues.append(value)
        }

        if includeInitial {
            expectedValues.insert(observables.initialValue, at: 0)
        }
        
        XCTAssertEqual(receivedValues, expectedValues)

        withExtendedLifetime(subscription) { }
    }

    func testValueIsCached() async throws {

        let observables = TestObservables()

        observables.$source.reset()
        _ = observables.awaited

        XCTAssertEqual(observables.$source.getWrappedValueInvocations.count, 0)
    }
}
