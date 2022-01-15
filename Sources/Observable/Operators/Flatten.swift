//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension Observable {

    public func flatten() -> AnyObservable<T.T> where T: Observable {

        FlattenObservable(
            source: self
        ).erase()
    }
}

class FlattenObservable<Source: Observable> : Observable {

    typealias T = Source.T
    
    var wrappedValue: T {

        source.wrappedValue.wrappedValue
    }

    init<SourceObservable: Observable>(
        source: SourceObservable
    ) where SourceObservable.T == Source {

        let erasedSource = source.erase();
        
        self.source = erasedSource
        
        self.subscriber = BroadcastSubsciber(sourceSubscriptionProvider: { handler in
            
            FlattenSubscription(
                source: erasedSource,
                handler: handler
            )
        })
    }

    func subscribeActual(_ handler: @escaping (T) -> Void) -> Subscription {

        subscriber.subscribe(handler)
    }

//    func publishUpdates() -> EventStream<T> {
//
//        // Capture inner source updates
//        var innerUpdates = source.wrappedValue.publishUpdates()
//
//        let outerUpdates = source.publishUpdates()
//
//        let sourceUpdates = outerUpdates
//            .map { innerValue -> EventStream<T> in
//
//                let captureOuterUpdates = outerUpdates
//
//                let innerStream = innerValue.publishUpdates()
//                innerUpdates = innerStream
//
//                return innerStream
//            }
//
//        return sourceUpdates
//            .switch()
//            .map { value in
//
//                // Make closure capture the outer source updates
//                let captureSourceUpdates = sourceUpdates
//
//                return value
//            }
//            .merge(innerUpdates)
//    }

    private class FlattenSubscription : Subscription {

        init(
            source: AnyObservable<Source>,
            handler: @escaping (T) -> Void
        ) {

            super.init()

            outerSubscription = source.subscribeActual { [weak self] innerSource in

                guard let strongSelf = self else {
                    return
                }

                strongSelf.innerSubscription = innerSource
                    .subscribe(notifyImmediately: true) { innerResult in handler(innerResult) }
            }
        }

        private var outerSubscription: Subscription! = nil
        private var innerSubscription: Subscription?
    }

    private let source: AnyObservable<Source>
    
    private let subscriber: BroadcastSubsciber<T>
}
