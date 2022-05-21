//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension EventStream {

    public func cacheLatest(initialValue: Value) -> AnyObservable<Value> {

        CacheLatestObservable(
            source: self,
            initialValue: initialValue
        ).erase()
    }
}

class CacheLatestObservable<T> : Observable {

    var wrappedValue: T {

        result.wrappedValue
    }

    init(
        source: EventStream<T>,
        initialValue: T
    ) {

        self.source = source
        
        let result = StoredObservable(wrappedValue: initialValue)
        self.result = result

        self.subscription = source
            .subscribe { value in result.wrappedValue = value }
    }

    func subscribeActual(_ handler: @escaping (T) -> Void) -> Subscription {

        result.subscribeActual(handler)
    }

    private let source: EventStream<T>
    private let result: StoredObservable<T>
    private let subscription: Subscription
}
