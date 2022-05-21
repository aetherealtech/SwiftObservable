//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer
import Scheduling

extension Observable {

    public func cache() -> AnyObservable<T> {

        cache(on: SynchronousScheduler())
    }

    public func cache(
        on scheduler: Scheduler
    ) -> AnyObservable<T> {

        CachedObservable(
            source: self,
            scheduler: scheduler
        ).erase()
    }
}

class CachedObservable<T> : Observable {

    var wrappedValue: T {

        cached.wrappedValue
    }

    init<SourceValue: Observable>(
        source: SourceValue,
        scheduler: Scheduler
    ) where SourceValue.T == T {

        let cached = StoredObservable(wrappedValue: source.wrappedValue)
        self.scheduler = scheduler

        self.cached = cached

        self.subscription = source.subscribe(notifyImmediately: false) { value in

            scheduler.run { cached.wrappedValue = value }
        }
    }

    func subscribeActual(_ handler: @escaping (T) -> Void) -> Subscription {

        cached.subscribeActual(handler)
    }

    private let cached: StoredObservable<T>
    private let subscription: Subscription

    private let scheduler: Scheduler
}
