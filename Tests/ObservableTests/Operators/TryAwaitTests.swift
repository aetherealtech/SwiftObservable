//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Scheduling
import Observer

@testable import Observable

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class TryAwaitTests: XCTestCase {

    class TestObservables {

        let initialValue = 10
        
        @MockObservable var source: Task<Int, Error> = TryAwaitTests.intTask(result: .success(8))

        @AnyObservable var awaited: Result<Int, Error>

        let scheduler = MockScheduler()

        init() {

            let channel = SimpleChannel<Task<Int, Error>>()

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

        XCTAssertEqual(try observables.awaited.get(), observables.initialValue)
        
        _ = try await observables.source.value
        try! await Task.sleep(nanoseconds: 100000)

        observables.scheduler.process()
        observables.scheduler.reset()

        let results = (0..<10).map { value -> Result<Int, Error> in

            if value % 4 == 1 {
                return .failure(NSError(domain: "", code: value))
            } else {
                return .success(value)
            }
        }

        for result in results {

            let oldTask = observables.source

            let newTask = Self.intTask(result: result)

            observables.source = newTask
            
            let oldValue = await oldTask.result
            let newValue = await newTask.result
            try! await Task.sleep(nanoseconds: 100000)
        
            XCTAssertEqual(observables.scheduler.runInvocations.count, 1)
            XCTAssertTrue(Self.compareResults(observables.awaited, oldValue))

            observables.scheduler.process()
            XCTAssertTrue(Self.compareResults(observables.awaited, newValue))

            observables.scheduler.reset()
        }
    }

    private static func compareResults(_ first: Result<Int, Error>, _ second: Result<Int, Error>) -> Bool {

        switch first {

        case .success(let firstValue):
            return firstValue == (try? second.get())

        case .failure(let firstError):
            guard case .failure(let secondError) = second else { return false }
            return (firstError as NSError).code == (secondError as NSError).code
        }
    }
    
    func testUpdate() async throws {

        await validateUpdates(includeInitial: false)
    }
    
    func testUpdateWithInitial() async throws {

        await validateUpdates(includeInitial: true)
    }

    private static func intTask(result: Result<Int, Error>) -> Task<Int, Error> {

        Task {

            try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<10000))

            return try result.get()
        }
    }

    private func validateUpdates(includeInitial: Bool) async {
        
        let observables = TestObservables()

        var receivedValues = [Result<Int, Error>]()
        
        let subscription = observables.$awaited
            .subscribe(notifyImmediately: includeInitial) { value in

                receivedValues.append(value)
            }
        
        var expectedValues = [Result<Int, Error>]()

        let firstValue = await observables.source.result
        try! await Task.sleep(nanoseconds: 100000)
        
        observables.scheduler.process()
        observables.scheduler.reset()

        expectedValues.append(firstValue)

        let results = (0..<10).map { value -> Result<Int, Error> in

            if value % 4 == 1 {
                return .failure(NSError(domain: "", code: value))
            } else {
                return .success(value)
            }
        }

        for result in results {

            let currentReceivedValues = receivedValues
            observables.source = Self.intTask(result: result)
            XCTAssertTrue(receivedValues.elementsEqual(currentReceivedValues, by: Self.compareResults))

            _ = await observables.source.result
            try! await Task.sleep(nanoseconds: 100000)
            
            observables.scheduler.process()
            observables.scheduler.reset()

            expectedValues.append(result)
        }

        if includeInitial {
            expectedValues.insert(.success(observables.initialValue), at: 0)
        }
        
        XCTAssertTrue(receivedValues.elementsEqual(expectedValues, by: Self.compareResults))

        withExtendedLifetime(subscription) { }
    }

    func testValueIsCached() async throws {

        let observables = TestObservables()

        observables.$source.reset()
        _ = observables.awaited

        XCTAssertEqual(observables.$source.getWrappedValueInvocations.count, 0)
    }
}
