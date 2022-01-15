//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Scheduling
import Observer

@testable import Observable

class CacheTests: XCTestCase {

    class TestObservables {

        @MockObservable var source: Int = 8
        @AnyObservable var cached: Int

        let scheduler = MockScheduler()

        init() {

            var channel: AnyTypedChannel<Int> = SimpleChannel()
                .asTypedChannel()

            let source = _source

            source.setWrappedValueSetup = { newValue in

                source.getWrappedValueSetup = { newValue }
                channel.publish(newValue)
            }

            source.subscribeSetup = channel.subscribe

            _cached = source
                .cache(on: scheduler)
        }
    }
    
    func testValue() throws {

        let observables = TestObservables()

        for value in 0..<10 {

            let oldValue = observables.source
            observables.source = value

            XCTAssertEqual(observables.scheduler.runInvocations.count, 1)
            XCTAssertEqual(observables.cached, oldValue)

            observables.scheduler.process()
            XCTAssertEqual(observables.cached, value)

            observables.scheduler.reset()
        }
    }
    
    func testUpdate() throws {

        validateUpdates(includeInitial: false)
    }
    
    func testUpdateWithInitial() throws {

        validateUpdates(includeInitial: true)
    }
    
    private func validateUpdates(includeInitial: Bool) {
        
        let observables = TestObservables()

        var receivedValues = [Int]()

        let subscription = observables.$cached
            .subscribe(notifyImmediately: includeInitial) { value in

                receivedValues.append(value)
            }

        let initialValue = observables.source
        
        var expectedValues = [Int]()

        for value in 0..<10 {

            let currentReceivedValues = receivedValues
            observables.source = value
            XCTAssertEqual(receivedValues, currentReceivedValues)

            observables.scheduler.process()
            observables.scheduler.reset()

            expectedValues.append(value)
        }

        if includeInitial {
            expectedValues.insert(initialValue, at: 0)
        }
        
        XCTAssertEqual(receivedValues, expectedValues)
    }
    
    func testPublishUpdates() throws {

        let observables = TestObservables()

        let publishedUpdates = observables.$cached.publishUpdates()
        
        var receivedValues = [Int]()

        let subscription = publishedUpdates
            .subscribe { value in

                receivedValues.append(value)
            }

        var expectedValues = [Int]()

        for value in 0..<10 {

            let currentReceivedValues = receivedValues
            observables.source = value
            XCTAssertEqual(receivedValues, currentReceivedValues)

            observables.scheduler.process()
            observables.scheduler.reset()

            expectedValues.append(value)
        }

        XCTAssertEqual(receivedValues, expectedValues)
    }

    func testValueIsCached() throws {

        let observables = TestObservables()

        observables.$source.reset()
        let value = observables.cached

        XCTAssertEqual(observables.$source.getWrappedValueInvocations.count, 0)
    }
}