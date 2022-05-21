//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import CoreExtensions
import EventStreams
import Observer

extension MutableObservable {

    public func atomic() -> AnyMutableObservable<T> {

        AtomicMutableObservable(
            source: self
        ).erase()
    }
}

class AtomicMutableObservable<T> : MutableObservable {

    var wrappedValue: T {

        get { lock.lock { source.wrappedValue } }
        set { lock.exclusiveLock { source.wrappedValue = newValue } }
    }

    init<SourceValue: MutableObservable>(
        source: SourceValue
    ) where SourceValue.T == T {

        self.source = source.erase()
    }

    func subscribeActual(_ handler: @escaping (T) -> Void) -> Subscription {

        source.subscribe(handler)
    }

    private let source: AnyMutableObservable<T>
    private let lock = ReadWriteLock()
}
