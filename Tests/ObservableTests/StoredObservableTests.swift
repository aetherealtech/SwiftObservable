//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

@testable import Observable

class StoredObservableTests: XCTestCase {

    class TestObservables {

        @StoredObservable var source: Int = 8
    }

    func testValue() throws {

        let observables = TestObservables()

        for value in 50...65 {
            observables.source = value
            XCTAssertEqual(observables.source, value)
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

        let subscription = observables.$source
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
        
        XCTAssertEqual(receivedValues, expectedValues)
        
        withExtendedLifetime(subscription) { }
    }
    
    func testPublishUpdates() throws {

        let observables = TestObservables()

        let publishedUpdates = observables.$source.publishUpdates()
        
        var receivedValues = [Int]()

        let subscription = publishedUpdates
            .subscribe { value in

                receivedValues.append(value)
            }
         
        let expectedValues = Array(50...65)
        
        for value in expectedValues {
            observables.source = value
        }
                
        XCTAssertEqual(receivedValues, expectedValues)
        
        withExtendedLifetime(subscription) { }
    }
}
