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
        
        self.subscriber = BroadcastSubscriber(sourceSubscriptionProvider: { handler in
            
            FlattenSubscription(
                source: erasedSource,
                handler: handler
            )
        })
    }

    func subscribeActual(_ handler: @escaping (T) -> Void) -> Subscription {

        subscriber.subscribe(handler)
    }

    private class FlattenSubscription : Subscription {

        init(
            source: AnyObservable<Source>,
            handler: @escaping (T) -> Void
        ) {

            super.init()

            outerSubscription = source
                    .subscribe(notifyImmediately: false) { [weak self] innerSource in

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
    
    private let subscriber: BroadcastSubscriber<T>
}
