//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

@propertyWrapper public class MutableObservable<T> : Observable {

    public var wrappedValue: T {

        get { _value }
        set {

            _value = newValue
            channel.publish(newValue)
        }
    }

    public var value: T {
        get { wrappedValue }
        set { wrappedValue = newValue }
    }

    public var projectedValue: MutableObservable<T> {

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
    private let channel: AnyTypedChannel<T> = SimpleChannel().asTypedChannel()
}