//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension Observable {

    public func map<T2>(_ transform: @escaping (T) -> T2) -> AnyObservable<T2> {

        MappedObservable(
            source: self,
            transform: transform
        ).erase()
    }
}

class MappedObservable<Source, Result> : Observable {

    typealias T = Result

    var wrappedValue: Result {

        transform(source.wrappedValue)
    }

    init<SourceValue: Observable>(
        source: SourceValue,
        transform: @escaping (Source) -> Result
    ) where SourceValue.T == Source {

        self.source = source.erase()
        self.transform = transform
        
        self.subscriber = BroadcastSubsciber(sourceSubscriptionProvider: { handler in
            
            source.subscribeActual { source in handler(transform(source)) }
        })
    }

    func subscribeActual(_ handler: @escaping (Result) -> Void) -> Subscription {

        subscriber.subscribe(handler)
    }

//    func publishUpdates() -> EventStream<T> {
//
//        let sourceUpdates = source.publishUpdates()
//        let transform = self.transform
//
//        return sourceUpdates.map { sourceValue in
//
//            // Make closure capture the source updates
//            let captureSourceUpdates = sourceUpdates
//
//            return transform(sourceValue)
//        }
//    }

    private let source: AnyObservable<Source>
    private let transform: (Source) -> Result
    
    private let subscriber: BroadcastSubsciber<Result>
}
