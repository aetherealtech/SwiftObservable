//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

extension Observable {

    public func flatMap<ResultObservable: Observable>(_ transform: @escaping (T) -> ResultObservable) -> AnyObservable<ResultObservable.T> {

        self
            .map(transform)
            .flatten()
    }
    
//    public func flatMap<ResultObservable: Observable>(_ transform: @escaping (T) -> ResultObservable) -> AnyObservable<ResultObservable.T> {
//
//        FlatMappedObservable(
//            source: self,
//            transform: transform
//        ).erase()
//    }
}

//class FlatMappedObservable<Source, Result> : Observable {
//
//    typealias T = Result
//
//    var wrappedValue: Result {
//
//        transform(source.wrappedValue).wrappedValue
//    }
//
//    init<SourceValue: Observable, ResultObservable: Observable>(
//        source: SourceValue,
//        transform: @escaping (Source) -> ResultObservable
//    ) where SourceValue.T == Source, ResultObservable.T == Result {
//
//        let erasedSource = source.erase();
//        let erasedTransform = { source in transform(source).erase() }
//
//        self.source = erasedSource
//        self.transform = erasedTransform
//
//        self.subscriber = BroadcastSubsciber(sourceSubscriptionProvider: { handler in
//
//            FlatMapSubscription(
//                source: erasedSource,
//                transform: erasedTransform,
//                handler: handler
//            )
//        })
//    }
//
//    func subscribeActual(_ handler: @escaping (Result) -> Void) -> Subscription {
//
//        subscriber.subscribe(handler)
//    }
//
//    func publishUpdates() -> EventStream<Result> {
//
//        let sourceUpdates = source.publishUpdates()
//        let transform = self.transform
//
//        // Capture inner source updates
//        var innerUpdates: EventStream<Result>?
//
//        return sourceUpdates.switchMap { sourceValue in
//
//            // Make closure capture the outer source updates
//            let captureSourceUpdates = sourceUpdates
//
//            let updates = transform(sourceValue).publishUpdates()
//            innerUpdates = updates
//
//            return updates
//        }
//    }
//
//    private class FlatMapSubscription : Subscription {
//
//        init(
//            source: AnyObservable<Source>,
//            transform: @escaping (Source) -> AnyObservable<Result>,
//            handler: @escaping (Result) -> Void
//        ) {
//
//            super.init()
//
//            outerSubscription = source.subscribeActual { [weak self] source in
//
//                guard let strongSelf = self else {
//                    return
//                }
//
//                let innerSource = transform(source)
//
//                strongSelf.innerSubscription = innerSource
//                    .subscribeActual { innerResult in handler(innerResult) }
//            }
//        }
//
//        private var outerSubscription: Subscription! = nil
//        private var innerSubscription: Subscription?
//    }
//
//    private let source: AnyObservable<Source>
//    private let transform: (Source) -> AnyObservable<Result>
//
//    private let subscriber: BroadcastSubsciber<Result>
//}
