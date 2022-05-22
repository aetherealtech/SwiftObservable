//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer
import Scheduling

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Observable {

    public func await<Value>(
        initialValue: Value
    ) -> AnyObservable<Value> where T == Task<Value, Never> {

        `await`(
            initialValue: initialValue,
            on: SynchronousScheduler()
        )
    }

    public func await<Value>(
        initialValue: Value,
        on scheduler: Scheduler
    ) -> AnyObservable<Value> where T == Task<Value, Never>  {

        AwaitObservable(
            source: self,
            initialValue: initialValue,
            scheduler: scheduler
        ).erase()
    }

    public func await<Value>(
        initialValue: Value
    ) -> AnyObservable<Result<Value, Error>> where T == Task<Value, Error> {

        `await`(
            initialValue: initialValue,
            on: SynchronousScheduler()
        )
    }

    public func await<Value>(
        initialValue: Value,
        on scheduler: Scheduler
    ) -> AnyObservable<Result<Value, Error>> where T == Task<Value, Error>  {

        TryAwaitObservable(
            source: self,
            initialValue: initialValue,
            scheduler: scheduler
        ).erase()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class AwaitObservable<T> : Observable {

    var wrappedValue: T {

        cached.wrappedValue
    }

    init<SourceValue: Observable>(
        source: SourceValue,
        initialValue: T,
        scheduler: Scheduler
    ) where SourceValue.T == Task<T, Never> {

        let cached = StoredObservable(wrappedValue: initialValue)
        self.scheduler = scheduler

        self.cached = cached

        self.subscription = source.subscribe(notifyImmediately: true) { valueTask in

            Task {

                let value = await valueTask.value

                scheduler.run {

                    cached.wrappedValue = value
                }
            }
        }
    }

    func subscribeActual(_ handler: @escaping (T) -> Void) -> Subscription {

        cached.subscribeActual(handler)
    }

    private let cached: StoredObservable<T>
    private let subscription: Subscription

    private let scheduler: Scheduler
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class TryAwaitObservable<T> : Observable {

    var wrappedValue: Result<T, Error> {

        cached.wrappedValue
    }

    init<SourceValue: Observable>(
        source: SourceValue,
        initialValue: T,
        scheduler: Scheduler
    ) where SourceValue.T == Task<T, Error> {

        let cached = StoredObservable<Result<T, Error>>(wrappedValue: .success(initialValue))
        self.scheduler = scheduler

        self.cached = cached

        self.subscription = source.subscribe(notifyImmediately: true) { valueTask in

            Task {

                let result = await valueTask.result

                scheduler.run {
                    
                    cached.wrappedValue = result
                }
            }
        }
    }

    func subscribeActual(_ handler: @escaping (Result<T, Error>) -> Void) -> Subscription {

        cached.subscribeActual(handler)
    }

    private let cached: StoredObservable<Result<T, Error>>
    private let subscription: Subscription

    private let scheduler: Scheduler
}
