//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension EventStream {

    public func accumulate<Result>(initialValue: Result, _ accumulator: @escaping (Result, Value) -> Result) -> AnyObservable<Result> {

        AccumulatingObservable(
            source: self,
            initialValue: initialValue,
            accumulator: accumulator
        ).erase()
    }
}

class AccumulatingObservable<Diff, Result> : Observable {

    typealias T = Result

    var wrappedValue: T {

        result.wrappedValue
    }

    init(
        source: EventStream<Diff>,
        initialValue: Result,
        accumulator: @escaping (Result, Diff) -> Result
    ) {

        let result = MutableObservable(wrappedValue: initialValue)
        self.result = result

        self.subscription = source
            .accumulate(
                initialValue: initialValue,
                accumulator
            )
            .subscribe { resultValue in result.wrappedValue = resultValue }
    }

    func subscribeActual(_ handler: @escaping (T) -> Void) -> Subscription {

        result.subscribeActual(handler)
    }

//    func publishUpdates() -> EventStream<T> {
//
//        result.publishUpdates()
//    }

    private let result: MutableObservable<T>
    private let subscription: Subscription
}
