//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

@testable import Observable

class FlatMapTests: XCTestCase {

    class TestObservables {

        @StoredObservable var source: Int = 0
        @AnyObservable var flatMapped: String

        let innerValues: [StoredObservable<String>] = (0..<10).map { _ in StoredObservable<String>(wrappedValue: "") }

        let transform: (Int) -> AnyObservable<String>

        init() {

            let innerValues = self.innerValues

            transform = { index in innerValues[index].erase() }

            _flatMapped = _source
                .flatMap(transform)
        }
    }
    
    func testValue() throws {

        let observables = TestObservables()

        for outerValue in 0..<10 {
            
            observables.source = outerValue
            XCTAssertEqual(observables.flatMapped, observables.innerValues[outerValue].wrappedValue)
            
            for innerIntValue in 50...65 {

                let innerValue = "\(innerIntValue)"
                observables.innerValues[outerValue].wrappedValue = innerValue
                XCTAssertEqual(observables.flatMapped, innerValue)
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

        var receivedValues = [String]()

        let subscription = observables.$flatMapped
            .subscribe(notifyImmediately: includeInitial) { value in

                receivedValues.append(value)
            }
 
        let initialValue = observables.innerValues[observables.source].wrappedValue
        
        var expectedValues = [String]()
        
        for outerValue in 0..<10 {
            
            observables.source = outerValue
            expectedValues.append(observables.innerValues[outerValue].wrappedValue)
            
            for innerIntValue in 50...65 {

                let innerValue = "\(innerIntValue)"
                observables.innerValues[outerValue].wrappedValue = innerValue
                expectedValues.append(innerValue)
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

        let publishedUpdates = observables.$flatMapped.publishUpdates()
        
        var receivedValues = [String]()

        let subscription = publishedUpdates
            .subscribe { value in

                receivedValues.append(value)
            }
         
        var expectedValues = [String]()
        
        for outerValue in 0..<10 {
            
            observables.source = outerValue
            expectedValues.append(observables.innerValues[outerValue].wrappedValue)
            
            for innerIntValue in 50...65 {

                let innerValue = "\(innerIntValue)"
                observables.innerValues[outerValue].wrappedValue = innerValue
                expectedValues.append(innerValue)
            }
        }
                
        XCTAssertEqual(receivedValues, expectedValues)
        
        withExtendedLifetime(subscription) { }
    }
}
