//
// Created by Daniel Coleman on 3/24/22.
//

import Foundation
import EventStreams
import Observer

@propertyWrapper public class StoredObservable<T> : MutableObservable {

    public var wrappedValue: T {

        get { _value }
        set {

            _value = newValue
            channel.publish(newValue)
        }
    }

    public var projectedValue: StoredObservable<T> {

        self
    }

    public init(wrappedValue: T) {

        self._value = wrappedValue
    }

    public func subscribeActual(
        _ handler: @escaping (T) -> Void
    ) -> Subscription {

        channel.subscribe(handler)
    }

    private var _value: T
    private let channel = SimpleChannel<T>()
}