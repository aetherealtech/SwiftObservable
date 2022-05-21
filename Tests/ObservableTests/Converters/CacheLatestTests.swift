//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Observer
import EventStreams

@testable import Observable

class CacheLatestTests: XCTestCase {

    class TestObservables {

        let initialValue = 15

        let source = SimpleChannel<Int>()
        let sourceStream: EventStream<Int>

        @AnyObservable var cachedLatest: Int

        init() {

            sourceStream = source.asStream()

            _cachedLatest = sourceStream
                .cacheLatest(initialValue: initialValue)
        }
    }

    func testValue() throws {

        let observables = TestObservables()

        XCTAssertEqual(observables.cachedLatest, observables.initialValue)

        for _ in 0..<10 {

            let value = Int.random(in: 5..<50)
            observables.source.publish(value)

            XCTAssertEqual(observables.cachedLatest, value)
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

        let subscription = observables.$cachedLatest
            .subscribe(notifyImmediately: includeInitial) { value in

            receivedValues.append(value)
        }

        let initialValue = observables.initialValue

        var expectedValues = [Int]()

        for _ in 0..<10 {

            let value = Int.random(in: 5..<50)
            observables.source.publish(value)

            expectedValues.append(value)
        }

        if includeInitial {
            expectedValues.insert(initialValue, at: 0)
        }

        XCTAssertEqual(receivedValues, expectedValues)
        
        withExtendedLifetime(subscription) { }
    }

    func testPublishUpdates() throws {

        let observables = TestObservables()

        let publishedUpdates = observables.$cachedLatest.publishUpdates()

        var receivedValues = [Int]()

        let subscription = publishedUpdates
            .subscribe { value in

            receivedValues.append(value)
        }

        var expectedValues = [Int]()

        for _ in 0..<10 {

            let value = Int.random(in: 5..<50)
            observables.source.publish(value)

            expectedValues.append(value)
        }

        XCTAssertEqual(receivedValues, expectedValues)
        
        withExtendedLifetime(subscription) { }
    }
}
