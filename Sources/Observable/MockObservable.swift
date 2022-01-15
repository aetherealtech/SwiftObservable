//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

import EventStreams
import Observer

@propertyWrapper public class MockObservable<T> : Observable {

    public var getWrappedValueInvocations: [Void] { _getWrappedValueInvocations }
    public var setWrappedValueInvocations: [T] { _setWrappedValueInvocations }

    public var getWrappedValueSetup: () -> T
    public var setWrappedValueSetup: (T) -> Void = { _ in }

    public var wrappedValue: T {

        get {

            _getWrappedValueInvocations.append(())
            return getWrappedValueSetup()
        }
        set {

            _setWrappedValueInvocations.append(newValue)
            setWrappedValueSetup(newValue)
        }
    }

    public var projectedValue: MockObservable<T> {

        self
    }

    public init(wrappedValue: T) {

        self.getWrappedValueSetup = { wrappedValue }
    }

    public var subscribeInvocations: [(T) -> Void] { _subscribeInvocations }

    public var subscribeSetup: ( @escaping (T) -> Void) -> Subscription = { _ in fatalError("subscribeActual not been mocked") }

    public func subscribeActual(
        _ handler: @escaping (T) -> Void
    ) -> Subscription {

        _subscribeInvocations.append(handler)
        return subscribeSetup(handler)
    }

    public func reset() {

        _getWrappedValueInvocations.removeAll()
        _setWrappedValueInvocations.removeAll()
        _subscribeInvocations.removeAll()
    }

    private var _getWrappedValueInvocations = [Void]()
    private var _setWrappedValueInvocations = [T]()
    private var _subscribeInvocations = [(T) -> Void]()
}