//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import EventStreams

@testable import Observable

class DifferencesTests: XCTestCase {

    class TestObservables {

        @MutableObservable var source: Int = 0

        let differences: EventStream<Int>

        init() {

            differences = _source
                .publishDifferences(-)
        }
    }

    func testUpdates() throws {

        let observables = TestObservables()

        var receivedValues = [Int]()

        let subscription = observables.differences
            .subscribe { value in

                receivedValues.append(value)
            }

        var currentValue = observables.source

        var expectedValues = [Int]()

        for value in 0..<10 {

            let nextValue = Int.random(in: 5..<50)
            let difference = nextValue - currentValue
            currentValue = nextValue

            observables.source = nextValue
            expectedValues.append(difference)
        }

        XCTAssertEqual(receivedValues, expectedValues)
    }
}