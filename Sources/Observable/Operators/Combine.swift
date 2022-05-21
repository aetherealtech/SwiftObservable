//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension Observable {

    public func combine<Other: Observable>(_ other: Other) -> AnyObservable<(T, Other.T)> {

        CombinedObservable(
            source1: self,
            source2: other
        ).erase()
    }

    public func combine<Other1: Observable, Other2: Observable>(
        _ other1: Other1,
        _ other2: Other2
    ) -> AnyObservable<(T, Other1.T, Other2.T)> {

        self.combine(other1)
            .combine(other2)
            .map { first, last in (first.0, first.1, last) }
            .erase()
    }

    public func combine<Other1: Observable, Other2: Observable, Other3: Observable>(
        _ other1: Other1,
        _ other2: Other2,
        _ other3: Other3
    ) -> AnyObservable<(T, Other1.T, Other2.T, Other3.T)> {

        self.combine(other1, other2)
            .combine(other3)
            .map { first, last in (first.0, first.1, first.2, last) }
            .erase()
    }

    public func combine<Other1: Observable, Other2: Observable, Other3: Observable, Other4: Observable>(
        _ other1: Other1,
        _ other2: Other2,
        _ other3: Other3,
        _ other4: Other4
    ) -> AnyObservable<(T, Other1.T, Other2.T, Other3.T, Other4.T)> {

        self.combine(other1, other2, other3)
            .combine(other4)
            .map { first, last in (first.0, first.1, first.2, first.3, last) }
            .erase()
    }
}

class CombinedObservable<T1, T2> : Observable {

    typealias T = (T1, T2)

    var wrappedValue: (T1, T2) {

        (source1.wrappedValue, source2.wrappedValue)
    }

    init<Source1: Observable, Source2: Observable>(
        source1: Source1,
        source2: Source2
    ) where Source1.T == T1, Source2.T == T2 {

        self.source1 = source1.erase()
        self.source2 = source2.erase()
        
        self.subscriber = BroadcastSubscriber(sourceSubscriptionProvider: { handler in

            let subscription1 = source1.subscribeActual { source1 in handler((source1, source2.wrappedValue)) }
            let subscription2 = source2.subscribeActual { source2 in handler((source1.wrappedValue, source2)) }

            return AggregateSubscription(Set<Subscription>([subscription1, subscription2]))
        })
    }

    func subscribeActual(_ handler: @escaping ((T1, T2)) -> Void) -> Subscription {

        subscriber.subscribe(handler)
    }

//    func publishUpdates() -> EventStream<(T1, T2)> {
//
//        let updates = (source1.publishUpdates(), source2.publishUpdates())
//
//        return updates.0
//            .combineLatest(updates.1)
//            .map { value -> (T1, T2) in
//
//                // Capture source updates
//                let captureUpdates = updates
//
//                return value
//            }
//    }

    private let source1: AnyObservable<T1>
    private let source2: AnyObservable<T2>
    
    private let subscriber: BroadcastSubscriber<T>
}

extension Array where Element: Observable {

    public func combine() -> AnyObservable<[Element.T]> {

        ArrayObservable(sources: self)
            .erase()
    }
}

class ArrayObservable<Element> : Observable {

    typealias T = [Element]
    
    var wrappedValue: T {

        sources.map { source in source.wrappedValue }
    }

    init<Source: Observable>(
        sources: [Source]
    ) where Source.T == Element {
        
        self.sources = sources.map { source in source.erase() }
        
        self.subscriber = BroadcastSubscriber(sourceSubscriptionProvider: { handler in

            let subscriptions = sources.enumerated().map { index, source in
                
                source.subscribeActual { value in
                    
                    let values: [Element] = (0..<sources.count).map { sourceIndex in
                        
                        if sourceIndex == index {
                            return value
                        }
                        
                        return sources[sourceIndex].wrappedValue
                    }
                    
                    handler(values)
                }
            }

            return AggregateSubscription(Set<Subscription>(subscriptions))
        })
    }

    func subscribeActual(_ handler: @escaping ([Element]) -> Void) -> Subscription {

        subscriber.subscribe(handler)
    }

    private let sources: [AnyObservable<Element>]
    private let subscriber: BroadcastSubscriber<T>
}
