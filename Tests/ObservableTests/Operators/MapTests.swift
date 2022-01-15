//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

@testable import Observable

class MapTests: XCTestCase {

    class TestObservables {

        @MutableObservable var source: Int = 8
        @AnyObservable var mapped: String

        let transform: (Int) -> String = { intValue in "\(intValue)" }
        
        init() {

            _mapped = _source
                .map(transform)
        }
    }
    
    func testValue() throws {

        let observables = TestObservables()

        for value in 50...65 {
            observables.source = value
            XCTAssertEqual(observables.mapped, observables.transform(value))
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
    }
    
    func testPublishUpdates() throws {

        let observables = TestObservables()

        let publishedUpdates = observables.$mapped.publishUpdates()
        
        var receivedValues = [String]()

        let subscription = publishedUpdates
            .subscribe { value in

                receivedValues.append(value)
            }
         
        var expectedValues = Array(50...65)
        
        for value in expectedValues {
            observables.source = value
        }
                
        XCTAssertEqual(receivedValues, expectedValues.map(observables.transform))
    }
}
