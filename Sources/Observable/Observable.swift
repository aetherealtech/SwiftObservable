//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

import EventStreams
import Observer
import Scheduling

public protocol Observable {

    associatedtype T

    var wrappedValue: T { get }

    func subscribeActual(
        _ handler: @escaping (T) -> Void
    ) -> Subscription
}

extension Observable {

    public var value: T { wrappedValue }

    public func subscribe(
        notifyImmediately: Bool = true,
        _ handler: @escaping (T) -> Void
    ) -> Subscription {

        let subscription = subscribeActual(handler)
        if notifyImmediately {
            handler(wrappedValue)
        }

        return subscription
    }
}

@propertyWrapper public class AnyObservable<T> : Observable {

    public var wrappedValue: T { wrappedValueImp() }

    public func subscribeActual(
        _ handler: @escaping (T) -> Void
    ) -> Subscription {

        subscribeActualImp(handler)
    }

    public func publishUpdates() -> EventStream<T> { publishUpdatesImp() }

    init<ObservableType: Observable>(
        erasing: ObservableType
    ) where ObservableType.T == T {

        self.wrappedValueImp = { erasing.wrappedValue }
        self.subscribeActualImp = erasing.subscribeActual
        self.publishUpdatesImp = erasing.publishUpdates
    }

    public var projectedValue: AnyObservable<T> { self }

    private let wrappedValueImp: () -> T
    private let subscribeActualImp: (@escaping (T) -> Void) -> Subscription
    private let publishUpdatesImp: () -> EventStream<T>
}

extension Observable {

    public func erase() -> AnyObservable<T> {

        AnyObservable(erasing: self)
    }
}

extension Observable {

    public func publishUpdates() -> EventStream<T> {

        EventStream(
            registerValues: { publish, _ in

                ObservableUpdates(
                    source: self,
                    publish: publish
                )
            },
            unregister: { source in

            }
        )
    }
}

class ObservableUpdates<SourceObservable: Observable>
{
    init(
        source: SourceObservable,
        publish: @escaping (SourceObservable.T) -> Void
    ) {

        self.source = source

        self.sourceSubscription = source.subscribe(publish)
    }

    let source: SourceObservable
    let sourceSubscription: Subscription
}