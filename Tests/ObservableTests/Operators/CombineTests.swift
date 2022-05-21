//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

@testable import Observable

class CombineTests: XCTestCase {

    class TestObservables {

        @StoredObservable var source1: Int = 0
        @StoredObservable var source2: String = ""

        @AnyObservable var combined: (Int, String)

        init() {

            _combined = _source1
                .combine(_source2)
        }
    }
    
    func testValue() throws {

        let observables = TestObservables()

        for value1 in 0..<10 {
            
            observables.source1 = value1
            XCTAssertTrue(observables.combined.0 == observables.source1 && observables.combined.1 == observables.source2)
        }

        for value2Int in 50...65 {

            let value2 = "\(value2Int)"

            observables.source2 = value2
            XCTAssertTrue(observables.combined.0 == observables.source1 && observables.combined.1 == observables.source2)
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

        var receivedValues = [(Int, String)]()

        let subscription = observables.$combined
            .subscribe(notifyImmediately: includeInitial) { value in

                receivedValues.append(value)
            }
 
        let initialValue = (observables.source1, observables.source2)
        
        var expectedValues = [(Int, String)]()

        for value1 in 0..<10 {

            observables.source1 = value1
            expectedValues.append((observables.source1, observables.source2))
        }

        for value2Int in 50...65 {

            let value2 = "\(value2Int)"

            observables.source2 = value2
            expectedValues.append((observables.source1, observables.source2))
        }

        if includeInitial {
            expectedValues.insert(initialValue, at: 0)
        }
        
        XCTAssertTrue(receivedValues.elementsEqual(expectedValues) { actual, expected in

            actual.0 == expected.0 &&
                actual.1 == expected.1
        })
        
        withExtendedLifetime(subscription) { }
    }
    
    func testPublishUpdates() throws {

        let observables = TestObservables()

        let publishedUpdates = observables.$combined.publishUpdates()
        
        var receivedValues = [(Int, String)]()

        let subscription = publishedUpdates
            .subscribe { value in

                receivedValues.append(value)
            }
         
        var expectedValues = [(Int, String)]()

        for value1 in 0..<10 {

            observables.source1 = value1
            expectedValues.append((observables.source1, observables.source2))
        }

        for value2Int in 50...65 {

            let value2 = "\(value2Int)"

            observables.source2 = value2
            expectedValues.append((observables.source1, observables.source2))
        }

        XCTAssertTrue(receivedValues.elementsEqual(expectedValues) { actual, expected in

            actual.0 == expected.0 &&
                actual.1 == expected.1
        })
        
        withExtendedLifetime(subscription) { }
    }
}
