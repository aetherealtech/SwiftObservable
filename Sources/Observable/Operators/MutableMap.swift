//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension MutableObservable {

    public func mutableMap<T2>(
        _ transform: @escaping (T) -> T2,
        _ inverseTransform: @escaping (T2) -> T
    ) -> AnyMutableObservable<T2> {

        MutableMappedObservable(
            source: self,
            transform: transform,
            inverseTransform: inverseTransform
        ).erase()
    }
}

class MutableMappedObservable<Source, Result> : MutableObservable {

    typealias T = Result

    var wrappedValue: Result {

        get { transform(source.wrappedValue) }
        set { source.wrappedValue = inverseTransform(newValue) }
    }

    init<SourceValue: MutableObservable>(
        source: SourceValue,
        transform: @escaping (Source) -> Result,
        inverseTransform: @escaping (Result) -> Source
    ) where SourceValue.T == Source {

        self.source = source.erase()

        self.transform = transform
        self.inverseTransform = inverseTransform
        
        self.subscriber = BroadcastSubscriber(sourceSubscriptionProvider: { handler in
            
            source.subscribeActual { source in handler(transform(source)) }
        })
    }

    func subscribeActual(_ handler: @escaping (Result) -> Void) -> Subscription {

        subscriber.subscribe(handler)
    }

    private let source: AnyMutableObservable<Source>

    private let transform: (Source) -> Result
    private let inverseTransform: (Result) -> Source
    
    private let subscriber: BroadcastSubscriber<Result>
}
