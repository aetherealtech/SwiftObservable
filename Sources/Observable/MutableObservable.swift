//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation
import EventStreams
import Observer

public protocol MutableObservable : Observable {

    var wrappedValue: T { get set }
}

extension MutableObservable {

    public var value: T {
        get { wrappedValue }
        set { wrappedValue = newValue }
    }
}

@propertyWrapper public class AnyMutableObservable<T> : MutableObservable {

    public var wrappedValue: T {

        get { getWrappedValue() }
        set { setWrappedValue(newValue) }
    }

    public var projectedValue: AnyMutableObservable<T> {

        self
    }

    public func subscribeActual(
        _ handler: @escaping (T) -> Void
    ) -> Subscription {

        subscribeActualImp(handler)
    }

    public init<Erasing: MutableObservable>(erasing: Erasing) where Erasing.T == T {

        getWrappedValue = { erasing.wrappedValue }
        setWrappedValue = { newValue in erasing.wrappedValue = newValue }

        subscribeActualImp = { handler in erasing.subscribeActual(handler) }
    }

    private let getWrappedValue: () -> T
    private let setWrappedValue: (T) -> Void

    private let subscribeActualImp: (@escaping (T) -> Void) -> Subscription
}

extension MutableObservable {

    func erase() -> AnyMutableObservable<T> {

        AnyMutableObservable(erasing: self)
    }
}