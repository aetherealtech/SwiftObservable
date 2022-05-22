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

@propertyWrapper public class AnyMutableObservable<T> :
    AnyObservable<T>,
    MutableObservable {

    public override var wrappedValue: T {

        get { super.wrappedValue }
        set { setWrappedValue(newValue) }
    }

    public override var projectedValue: AnyMutableObservable<T> {

        self
    }

    public init<Erasing: MutableObservable>(erasing: Erasing) where Erasing.T == T {

        setWrappedValue = { newValue in erasing.wrappedValue = newValue }

        super.init(erasing: erasing)
    }

    private let setWrappedValue: (T) -> Void
}

extension MutableObservable {

    func erase() -> AnyMutableObservable<T> {

        AnyMutableObservable(erasing: self)
    }
}