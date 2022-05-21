//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

@testable import Observable

class CombineArrayTests: XCTestCase {

    class TestObservables {

        let sources: [StoredObservable<Int>] = (0..<10).map { _ in StoredObservable(wrappedValue: 0) }

        @AnyObservable var combined: [Int]

        init() {

            _combined = sources
                .combine()
        }
    }
    
    func testValue() throws {

        let observables = TestObservables()

        var expectedValue = observables.sources
            .map { source in source.wrappedValue }

        for (index, source) in observables.sources.enumerated() {

            for value in 0..<10 {

                source.wrappedValue = value
                expectedValue[index] = value

                XCTAssertEqual(observables.combined, expectedValue)
            }
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

        var receivedValues = [[Int]]()

        let subscription = observables.$combined
            .subscribe(notifyImmediately: includeInitial) { value in

                receivedValues.append(value)
            }

        var expectedValue = observables.sources
            .map { source in source.wrappedValue }

        let initialValue = expectedValue
        
        var expectedValues = [[Int]]()

        for (index, source) in observables.sources.enumerated() {

            for value in 0..<10 {

                source.wrappedValue = value
                expectedValue[index] = value
                expectedValues.append(expectedValue)
            }
        }

        if includeInitial {
            expectedValues.insert(initialValue, at: 0)
        }
        
        XCTAssertEqual(receivedValues, expectedValues)
        
        withExtendedLifetime(subscription) { }
    }
    
    func testPublishUpdates() throws {

        let observables = TestObservables()

        let publishedUpdates = observables.$combined.publishUpdates()
        
        var receivedValues = [[Int]]()

        let subscription = publishedUpdates
            .subscribe { value in

                receivedValues.append(value)
            }

        var expectedValue = observables.sources
            .map { source in source.wrappedValue }

        var expectedValues = [[Int]]()

        for (index, source) in observables.sources.enumerated() {

            for value in 0..<10 {

                source.wrappedValue = value
                expectedValue[index] = value
                expectedValues.append(expectedValue)
            }
        }

        XCTAssertEqual(receivedValues, expectedValues)
        
        withExtendedLifetime(subscription) { }
    }
}
