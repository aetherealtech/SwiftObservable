//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

@testable import Observable

class MutableMapTests: XCTestCase {

    class TestObservables {

        @StoredObservable var source: Int = 8
        @AnyMutableObservable var mapped: String

        let transform: (Int) -> String = { intValue in "\(intValue)" }
        let inverseTransform: (String) -> Int = { stringValue in Int(stringValue)! }
        
        init() {

            _mapped = _source
                .mutableMap(transform, inverseTransform)
        }
    }
    
    func testValue() throws {

        let observables = TestObservables()

        for value in 50...65 {
            observables.source = value
            XCTAssertEqual(observables.mapped, observables.transform(value))
        }
    }

    func testInverseValue() throws {

        let observables = TestObservables()

        for value in 50...65 {
            observables.mapped = observables.transform(value)
            XCTAssertEqual(observables.source, value)
        }
    }
    
    func testUpdate() throws {

        validateUpdates(includeInitial: false)
    }
    
    func testUpdateWithInitial() throws {

        validateUpdates(includeInitial: true)
    }

    func testInverseUpdate() throws {

        validateInverseUpdates(includeInitial: false)
    }

    func testInverseUpdateWithInitial() throws {

        validateInverseUpdates(includeInitial: true)
    }

    private func validateUpdates(includeInitial: Bool) {

        let observables = TestObservables()

        var receivedValues = [String]()

        let subscription = observables.$mapped
                .subscribe(notifyImmediately: includeInitial) { value in

                    receivedValues.append(value)
                }

        let initialValue = observables.source

        var expectedValues = Array(50...65)

        for value in expectedValues {
            observables.source = value
        }

        if includeInitial {
            expectedValues.insert(initialValue, at: 0)
        }

        XCTAssertEqual(receivedValues, expectedValues.map(observables.transform))

        withExtendedLifetime(subscription) { }
    }

    private func validateInverseUpdates(includeInitial: Bool) {

        let observables = TestObservables()

        var receivedValues = [Int]()

        let subscription = observables.$source
                .subscribe(notifyImmediately: includeInitial) { value in

                    receivedValues.append(value)
                }

        let initialValue = observables.mapped

        var expectedValues = (50...65).map(observables.transform)

        for value in expectedValues {
            observables.mapped = value
        }

        if includeInitial {
            expectedValues.insert(initialValue, at: 0)
        }

        XCTAssertEqual(receivedValues, expectedValues.map(observables.inverseTransform))

        withExtendedLifetime(subscription) { }
    }
}
