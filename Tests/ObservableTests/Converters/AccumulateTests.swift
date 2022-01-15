//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Observer
import EventStreams

@testable import Observable

class AccumulateTests: XCTestCase {

    class TestObservables {

        let initialValue = 15

        let source: AnyTypedChannel<Int> = SimpleChannel().asTypedChannel()
        let sourceStream: EventStream<Int>

        @AnyObservable var accumulated: Int

        init() {

            sourceStream = source.asStream()

            var channel: AnyTypedChannel<Int> = SimpleChannel()
                .asTypedChannel()

            _accumulated = sourceStream
                .accumulate(
                    initialValue: initialValue,
                    +
                )
        }
    }

    func testValue() throws {

        let observables = TestObservables()

        var expectedValue = observables.initialValue
        XCTAssertEqual(observables.accumulated, expectedValue)

        for value in 0..<10 {

            let increment = Int.random(in: 5..<50)
            observables.source.publish(increment)

            expectedValue += increment
            XCTAssertEqual(observables.accumulated, expectedValue)
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

        let subscription = observables.$accumulated
            .subscribe(notifyImmediately: includeInitial) { value in

                receivedValues.append(value)
            }

        var expectedValue = observables.initialValue
        let initialValue = expectedValue

        var expectedValues = [Int]()

        for value in 0..<10 {

            let increment = Int.random(in: 5..<50)
            observables.source.publish(increment)

            expectedValue += increment
            expectedValues.append(expectedValue)
        }

        if includeInitial {
            expectedValues.insert(initialValue, at: 0)
        }

        XCTAssertEqual(receivedValues, expectedValues)
    }

    func testPublishUpdates() throws {

        let observables = TestObservables()

        let publishedUpdates = observables.$accumulated.publishUpdates()
        
        var receivedValues = [Int]()

        let subscription = publishedUpdates
            .subscribe { value in

                receivedValues.append(value)
            }

        var expectedValue = observables.initialValue

        var expectedValues = [Int]()

        for value in 0..<10 {

            let increment = Int.random(in: 5..<50)
            observables.source.publish(increment)

            expectedValue += increment
            expectedValues.append(expectedValue)
        }

        XCTAssertEqual(receivedValues, expectedValues)
    }
}