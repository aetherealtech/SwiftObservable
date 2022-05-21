//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

@testable import Observable

class FlattenTests: XCTestCase {

    class TestObservables {

        @StoredObservable var source: StoredObservable<Int> = StoredObservable(wrappedValue: 8)
        @AnyObservable var flattened: Int
        
        init() {

            _flattened = _source
                .flatten()
        }
    }
    
    func testValue() throws {

        let observables = TestObservables()

        for outerValue in 0..<10 {
            
            observables.source = StoredObservable(wrappedValue: outerValue)
            XCTAssertEqual(observables.flattened, outerValue)
            
            for innerValue in 50...65 {
                
                observables.source.wrappedValue = innerValue
                XCTAssertEqual(observables.flattened, innerValue)
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

        var receivedValues = [Int]()

        let subscription = observables.$flattened
            .subscribe(notifyImmediately: includeInitial) { value in

                receivedValues.append(value)
            }
 
        let initialValue = observables.source.projectedValue
        
        var expectedValues = [Int]()
        
        for outerValue in 0..<10 {
            
            observables.source = StoredObservable(wrappedValue: outerValue)
            expectedValues.append(outerValue)
            
            for innerValue in 50...65 {
                
                observables.source.wrappedValue = innerValue
                expectedValues.append(innerValue)
            }
        }
        
        if includeInitial {
            expectedValues.insert(initialValue.wrappedValue, at: 0)
        }
        
        XCTAssertEqual(receivedValues, expectedValues)
        
        withExtendedLifetime(subscription) { }
    }
    
    func testPublishUpdates() throws {

        let observables = TestObservables()

        let publishedUpdates = observables.$flattened.publishUpdates()
        
        var receivedValues = [Int]()

        let subscription = publishedUpdates
            .subscribe { value in

                receivedValues.append(value)
            }
         
        var expectedValues = [Int]()
        
        for outerValue in 0..<10 {
            
            observables.source = StoredObservable(wrappedValue: outerValue)
            expectedValues.append(outerValue)
            
            for innerValue in 50...65 {
                
                observables.source.wrappedValue = innerValue
                expectedValues.append(innerValue)
            }
        }
                
        XCTAssertEqual(receivedValues, expectedValues)
        
        withExtendedLifetime(subscription) { }
    }
}
